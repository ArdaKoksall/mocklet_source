import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mocklet_source/app/data/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildPoweredBy(BuildContext context) {
  final theme = Theme.of(context);
  final textStyle = theme.textTheme.bodySmall?.copyWith(
    color: theme.textTheme.bodySmall?.color?.withOpacityValue(0.6),
  );
  final linkStyle = theme.textTheme.bodySmall?.copyWith(
    color: theme.primaryColor,
    decoration: TextDecoration.underline,
    decorationColor: theme.primaryColor,
  );

  return Center(
    child: RichText(
      text: TextSpan(
        text: 'Powered by ',
        style: textStyle,
        children: <TextSpan>[
          TextSpan(
            text: 'CoinGecko API',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final url = Uri.parse('https://www.coingecko.com/en/api');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
          ),
        ],
      ),
    ),
  );
}
