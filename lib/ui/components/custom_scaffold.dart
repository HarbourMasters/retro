import 'package:flutter/material.dart';

// ignore: constant_identifier_names
const CONTENT_PADDING_VERTICAL = 15.0;
// ignore: constant_identifier_names
const CONTENT_PADDING_HORIZONTAL = 15.0;

class CustomScaffold extends StatelessWidget {

  const CustomScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.onBackButtonPressed,
    this.topRightWidget,
    required this.content,
  });
  final String title;
  final String? subtitle;
  // modifier
  final Function? onBackButtonPressed;
  final Widget? topRightWidget;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          top:   CONTENT_PADDING_VERTICAL,
          left: CONTENT_PADDING_HORIZONTAL,
          right: CONTENT_PADDING_HORIZONTAL,
        ),
        child: Column(
          children: [
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  // back button
                  if (onBackButtonPressed != null)
                    IconButton(
                      icon: const Icon(Icons.chevron_left_outlined),
                      color: Colors.white,
                      splashRadius: 30,
                      onPressed: () => onBackButtonPressed!(),
                    ),

                  // title
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: textTheme.headlineSmall ),
                      if (subtitle != null)
                      Text(subtitle!, style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),),
                      ),
                    ],
                  ),
                  // top right widget
                  if (topRightWidget != null)
                    Expanded(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: topRightWidget!,),),

                ],
              ),
            ),
            content
          ],
        ),
      ),
    );
  }
}
