import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../utils/colors.dart';
import '../../utils/constants.dart';

String? _ytId(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  final host = uri.host.toLowerCase();
  if (host.contains('youtu.be')) {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  }
  if (host.contains('youtube.com')) {
    final segs = uri.pathSegments;
    final si = segs.indexOf('shorts');
    if (si >= 0 && si + 1 < segs.length) return segs[si + 1];
    final ei = segs.indexOf('embed');
    if (ei >= 0 && ei + 1 < segs.length) return segs[ei + 1];
    return uri.queryParameters['v'];
  }
  return null;
}

Future<void> _open(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    try { await launchUrl(uri); } catch (_) {}
  }
}

class _Work {
  final String label;
  final String sub;
  final IconData icon;
  final List<Color> gradient;
  final String? imageUrl;
  final String? videoUrl;
  final bool isYoutube;
  const _Work(this.label, this.sub, this.icon, this.gradient,
      {this.imageUrl, this.videoUrl, this.isYoutube = false});
}

const _kFallback = <_Work>[
  _Work('Hair Styling', 'Cuts, color & treatments', Icons.content_cut,
      [Color(0xFF3D1A00), Color(0xFF7B3F00)]),
  _Work('Bridal Look', 'Complete bridal packages', Icons.favorite,
      [Color(0xFF4A1A40), Color(0xFF8B3070)]),
  _Work('Nail Art', 'Manicure & nail design', Icons.back_hand_outlined,
      [Color(0xFF4A0010), Color(0xFF9B1B30)]),
  _Work('Spa & Relax', 'Massage & body care', Icons.spa,
      [Color(0xFF0A2A1A), Color(0xFF1B5E40)]),
  _Work('Facial Glow', 'Skin & facial treatments', Icons.face_retouching_natural,
      [Color(0xFF3A2800), Color(0xFF8B6914)]),
  _Work('Mehedi Art', 'Henna & mehedi designs', Icons.brush_outlined,
      [Color(0xFF2A0A00), Color(0xFF7B3010)]),
];

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});
  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<_Work> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await http.get(
          Uri.parse('${AppConstants.apiBaseUrl}${ApiEndpoints.gallery}'));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List list = (body is Map && body['data'] is List) ? body['data'] : [];
        final items = <_Work>[];
        for (final e in list) {
          final type = (e['type'] ?? 'image').toString();
          final url = (e['url'] ?? '').toString();
          if (url.isEmpty) continue;
          final title = (e['title'] ?? '').toString();
          final caption = (e['caption'] ?? '').toString();
          if (type == 'video') {
            final yt = _ytId(url);
            if (yt != null) {
              items.add(_Work(title.isEmpty ? 'Video' : title, caption, Icons.play_circle,
                  const [Color(0xFF0A1A2A), Color(0xFF1B3B5E)],
                  imageUrl: 'https://img.youtube.com/vi/$yt/hqdefault.jpg',
                  videoUrl: url, isYoutube: true));
            } else {
              items.add(_Work(title.isEmpty ? 'Video' : title, caption, Icons.play_circle,
                  const [Color(0xFF0A1A2A), Color(0xFF1B3B5E)], videoUrl: url));
            }
          } else {
            items.add(_Work(title.isEmpty ? 'Photo' : title, caption, Icons.image,
                const [Color(0xFF2A2620), Color(0xFF17150F)], imageUrl: url));
          }
        }
        if (mounted) setState(() { _items = items.isNotEmpty ? items : _kFallback; _loading = false; });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() { _items = _kFallback; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.surface,
              toolbarHeight: 88,
              titleSpacing: 20,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
                  ),
                ),
              ),
              title: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset('assets/images/app_icon.png', width: 30, height: 30, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Noor Beauty Salon',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
                      Text('Our Work',
                          style: TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            if (_loading)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.80),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _WorkCard(work: _items[i]),
                    childCount: _items.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _WorkCard extends StatefulWidget {
  final _Work work;
  const _WorkCard({required this.work});
  @override
  State<_WorkCard> createState() => _WorkCardState();
}

class _WorkCardState extends State<_WorkCard> {
  bool _active = false;
  void _set(bool v) { if (_active != v) setState(() => _active = v); }

  @override
  Widget build(BuildContext context) {
    final w = widget.work;
    final hasImage = w.imageUrl != null;
    final hasVideo = w.videoUrl != null;
    return MouseRegion(
      onEnter: (_) => _set(true),
      onExit: (_) => _set(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transformAlignment: Alignment.center,
        transform: _active ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _active ? AppColors.primary : AppColors.cardBorder,
            width: _active ? 1.6 : 1,
          ),
          boxShadow: _active
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 18, spreadRadius: 1)]
              : const [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: AppColors.primary.withValues(alpha: 0.25),
              highlightColor: AppColors.primary.withValues(alpha: 0.10),
              onTapDown: (_) => _set(true),
              onTapCancel: () => _set(false),
              onTap: () {
                _set(false);
                if (w.isYoutube && w.videoUrl != null) {
                  _open(w.videoUrl!);
                } else if (w.videoUrl != null) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => _VideoPage(url: w.videoUrl!, title: w.label),
                  ));
                }
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    Image.network(w.imageUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _bg(w),
                        loadingBuilder: (ctx, child, prog) => prog == null ? child : _bg(w))
                  else
                    _bg(w),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter, end: Alignment.center,
                        colors: [Colors.black.withValues(alpha: 0.82), Colors.transparent],
                      ),
                    ),
                  ),
                  if (hasVideo)
                    Center(
                      child: Container(
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), shape: BoxShape.circle),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                      ),
                    ),
                  Positioned(
                    left: 12, right: 12, bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!hasImage) Icon(w.icon, color: AppColors.primary, size: 22),
                        if (!hasImage) const SizedBox(height: 6),
                        Text(w.label,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        if (w.sub.isNotEmpty)
                          Text(w.sub,
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bg(_Work w) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight, colors: w.gradient,
          ),
        ),
      );
}

class _VideoPage extends StatefulWidget {
  final String url;
  final String title;
  const _VideoPage({required this.url, required this.title});
  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage> {
  late VideoPlayerController _c;
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _c.play();
        _c.addListener(_tick);
      }).catchError((e) {
        if (!mounted) return;
        setState(() => _error = e.toString());
      });
  }

  void _tick() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    _c.removeListener(_tick);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, title: Text(widget.title)),
      body: Center(
        child: _error != null
            ? Padding(padding: const EdgeInsets.all(24),
                child: Text('Video load hoyni:\n${_error!}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)))
            : _ready
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    AspectRatio(aspectRatio: _c.value.aspectRatio == 0 ? 16 / 9 : _c.value.aspectRatio, child: VideoPlayer(_c)),
                    const SizedBox(height: 8),
                    VideoProgressIndicator(_c, allowScrubbing: true, colors: VideoProgressColors(playedColor: AppColors.primary)),
                  ])
                : CircularProgressIndicator(color: AppColors.primary),
      ),
      floatingActionButton: _ready
          ? FloatingActionButton(
              backgroundColor: AppColors.primary, foregroundColor: Colors.black,
              onPressed: () => _c.value.isPlaying ? _c.pause() : _c.play(),
              child: Icon(_c.value.isPlaying ? Icons.pause : Icons.play_arrow))
          : null,
    );
  }
}