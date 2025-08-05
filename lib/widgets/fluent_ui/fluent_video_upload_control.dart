import 'package:fluent_ui/fluent_ui.dart';
import 'package:file_picker/file_picker.dart';

/// FluentUI风格的上传视频开始播放控件
class FluentVideoUploadControl extends StatefulWidget {
  final Function(String filePath)? onVideoSelected;
  final Function(List<String> filePaths)? onVideosSelected;
  final bool allowMultiple;
  final List<String> allowedExtensions;
  final String? title;
  final String? subtitle;
  final IconData? icon;

  const FluentVideoUploadControl({
    super.key,
    this.onVideoSelected,
    this.onVideosSelected,
    this.allowMultiple = false,
    this.allowedExtensions = const ['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'm4v'],
    this.title,
    this.subtitle,
    this.icon,
  });

  @override
  State<FluentVideoUploadControl> createState() => _FluentVideoUploadControlState();
}

class _FluentVideoUploadControlState extends State<FluentVideoUploadControl>
    with TickerProviderStateMixin {
  bool _isHovering = false;
  bool _isDragging = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
        allowMultiple: widget.allowMultiple,
      );

      if (result != null) {
        if (widget.allowMultiple && widget.onVideosSelected != null) {
          final filePaths = result.paths.where((path) => path != null).cast<String>().toList();
          widget.onVideosSelected!(filePaths);
        } else if (!widget.allowMultiple && widget.onVideoSelected != null) {
          final filePath = result.files.single.path;
          if (filePath != null) {
            widget.onVideoSelected!(filePath);
          }
        }
      }
    } catch (e) {
      // 处理文件选择错误
      debugPrint('文件选择错误: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _scaleController.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _scaleController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(12),
          backgroundColor: _isHovering 
              ? theme.accentColor.withOpacity(0.05)
              : theme.cardColor,
          child: GestureDetector(
            onTap: _pickVideo,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isHovering || _isDragging
                      ? theme.accentColor.withOpacity(0.6)
                      : theme.inactiveColor.withOpacity(0.3),
                  width: 2,
                  style: _isDragging ? BorderStyle.solid : BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 图标
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: (_isHovering || _isDragging)
                          ? theme.accentColor.withOpacity(0.1)
                          : theme.inactiveColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon ?? FluentIcons.video,
                      size: 40,
                      color: (_isHovering || _isDragging)
                          ? theme.accentColor
                          : theme.inactiveColor,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 主标题
                  Text(
                    widget.title ?? (widget.allowMultiple ? '选择视频文件' : '选择视频文件'),
                    style: theme.typography.subtitle?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: (_isHovering || _isDragging)
                          ? theme.accentColor
                          : null,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 副标题
                  Text(
                    widget.subtitle ?? 
                        '支持 ${widget.allowedExtensions.map((e) => e.toUpperCase()).join(', ')} 格式\n${widget.allowMultiple ? '可选择多个文件' : '单击选择文件'}',
                    style: theme.typography.caption?.copyWith(
                      color: theme.inactiveColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 按钮
                  FilledButton(
                    onPressed: _pickVideo,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FluentIcons.folder_open,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(widget.allowMultiple ? '浏览文件' : '浏览文件'),
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
}

/// FluentUI风格的紧凑视频上传按钮
class FluentVideoUploadButton extends StatelessWidget {
  final Function(String filePath)? onVideoSelected;
  final bool isLoading;
  final String? label;
  final IconData? icon;

  const FluentVideoUploadButton({
    super.key,
    this.onVideoSelected,
    this.isLoading = false,
    this.label,
    this.icon,
  });

  Future<void> _pickVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'm4v'],
        allowMultiple: false,
      );

      if (result != null && onVideoSelected != null) {
        final filePath = result.files.single.path;
        if (filePath != null) {
          onVideoSelected!(filePath);
        }
      }
    } catch (e) {
      debugPrint('文件选择错误: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : _pickVideo,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: ProgressRing(),
            )
          else
            Icon(
              icon ?? FluentIcons.video,
              size: 16,
            ),
          const SizedBox(width: 8),
          Text(isLoading ? '加载中...' : (label ?? '选择视频')),
        ],
      ),
    );
  }
}