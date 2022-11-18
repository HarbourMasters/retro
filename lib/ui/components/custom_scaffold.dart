import 'package:flutter/material.dart';

// ignore: constant_identifier_names
const CONTENT_PADDING_VERTICAL = 15.0;
// ignore: constant_identifier_names
const CONTENT_PADDING_HORIZONTAL = 15.0;

class CustomScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  // modifier
  final Function? onBackButtonPressed;
  final Widget? topRightWidget;
  final Widget content;

  const CustomScaffold({
    Key? key,
    required this.title,
    this.subtitle,
    this.onBackButtonPressed,
    this.topRightWidget,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
        body: SizedBox.expand(
            child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: CONTENT_PADDING_VERTICAL,
                    horizontal: CONTENT_PADDING_HORIZONTAL),
                child: Column(children: [
                  SizedBox(
                      height: 60,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // back button
                          if (onBackButtonPressed != null)
                            IconButton(
                              icon: const Icon(Icons.chevron_left_outlined),
                              color: Colors.white,
                              splashRadius: 30,
                              onPressed: () => onBackButtonPressed!(),
                            ),
                          const SizedBox(width: 15),

                          // title
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: textTheme.headline5,
                              ),
                              if (subtitle != null)
                                Text(subtitle!,
                                    style: textTheme.bodyText2?.copyWith(
                                        color: colorScheme.onSurface
                                            .withOpacity(0.5))),
                            ],
                          ),
                          // top right widget
                          if (topRightWidget != null)
                            Container(
                              width: double.infinity,
                              alignment: Alignment.centerRight,
                              child: topRightWidget,
                            ),
                        ],
                      )),
                  // 10 dp space
                  const SizedBox(height: 10),
                  // content
                  Container(
                    child: content,
                  ),
                ]))));
  }
}
