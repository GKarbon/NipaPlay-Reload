import 'package:flutter/material.dart';
import 'package:nipaplay/danmaku_abstraction/danmaku_content_item.dart';
import 'package:nipaplay/utils/globals.dart' as globals;

/// 弹幕文本渲染器的抽象基类
abstract class DanmakuTextRenderer {
  const DanmakuTextRenderer();

  /// 构建并渲染弹幕文本
  ///
  /// [context] - 构建上下文
  /// [content] - 弹幕内容项
  /// [fontSize] - 基础字体大小
  /// [opacity] - 透明度
  Widget build(
    BuildContext context,
    DanmakuContentItem content,
    double fontSize,
    double opacity,
  );
}

/// 使用CPU进行文本渲染的实现类
class CpuDanmakuTextRenderer extends DanmakuTextRenderer {
  const CpuDanmakuTextRenderer();

  @override
  Widget build(
    BuildContext context,
    DanmakuContentItem content,
    double fontSize,
    double opacity,
  ) {
    // 计算弹幕颜色的亮度
    final color = content.color;
    final luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    // 如果亮度小于0.2，说明是深色，使用白色描边；否则使用黑色描边
    final strokeColor = luminance < 0.2 ? Colors.white : Colors.black;

    // 应用字体大小倍率
    final adjustedFontSize = fontSize * content.fontSizeMultiplier;

    // 检查是否有计数文本
    final hasCountText = content.countText != null;

    // 创建阴影列表，移动端使用更细的描边
     
    final shadowList = [
      Shadow(offset: Offset(-globals.strokeWidth, -globals.strokeWidth), blurRadius: 0, color: strokeColor),
      Shadow(offset: Offset(globals.strokeWidth, -globals.strokeWidth), blurRadius: 0, color: strokeColor),
      Shadow(offset: Offset(globals.strokeWidth, globals.strokeWidth), blurRadius: 0, color: strokeColor),
      Shadow(offset: Offset(-globals.strokeWidth, globals.strokeWidth), blurRadius: 0, color: strokeColor),
      Shadow(offset: Offset(0, -globals.strokeWidth), blurRadius: 0, color: strokeColor),
      Shadow(offset: Offset(0, globals.strokeWidth), blurRadius: 0, color: strokeColor),
      Shadow(offset: Offset(-globals.strokeWidth, 0), blurRadius: 0, color: strokeColor),
      Shadow(offset: Offset(globals.strokeWidth, 0), blurRadius: 0, color: strokeColor),
    ];

    final textWidget = hasCountText
        ? RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: content.text,
                  locale:Locale("zh-Hans","zh"),
style: TextStyle(
                    fontSize: adjustedFontSize,
                    color: content.color,
                    fontWeight: FontWeight.normal,
                    shadows: shadowList,
                  ),
                ),
                TextSpan(
                  text: content.countText,
                  locale:Locale("zh-Hans","zh"),
style: TextStyle(
                    fontSize: 25.0, // 固定大小字体
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: shadowList, // 继承相同的描边效果
                  ),
                ),
              ],
            ),
          )
        : Stack(
            children: [
              // 描边
              Text(
                content.text,
                locale:Locale("zh-Hans","zh"),
style: TextStyle(
                  fontSize: adjustedFontSize,
                  color: strokeColor,
                  fontWeight: FontWeight.normal,
                  shadows: shadowList,
                ),
              ),
              // 实际文本
              Text(
                content.text,
                locale:Locale("zh-Hans","zh"),
style: TextStyle(
                  fontSize: adjustedFontSize,
                  color: content.color,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          );

    return Opacity(
      opacity: opacity,
      child: content.isMe
          ? Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: textWidget,
            )
          : textWidget,
    );
  }
} 