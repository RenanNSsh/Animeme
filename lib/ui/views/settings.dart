import 'dart:io';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/utils/dialog_utils.dart';
import '../../core/utils/theme.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../widgets/card_with_children.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with AutomaticKeepAliveClientMixin<SettingsPage> {
  @override
  bool get wantKeepAlive => true;
  String cacheSize = 'N/A';
  static const String appUrl =
          'https://play.google.com/store/apps/details?id=com.renannssh.animeme',
      codeUrl = 'https://github.com/RenanNSsh/Animeme',
      issuesUrl = 'mailto:renan.sanches@exception.com.br?subject=Reportar erro&body=Gostaria%20de%20reportar%20o%20seguinte%20erro:';

  @override
  void initState() {
    super.initState();
    getCacheSize();
  }

  void getCacheSize() async {
    final directory = Directory(await DefaultCacheManager().getFilePath());
    if (directory.existsSync()) {
      FileStat fileStat = directory.statSync();
      cacheSize = '${(fileStat.size / 1024.0)} MB';
      setState(() {});
    }
  }

  clearCache() async {
    try {
      await DefaultCacheManager().emptyCache();
    } catch (e) {
      print(e);
    }
    getCacheSize();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final ThemeData state = themeNotifier.getTheme();

    return Container(
      color: state.primaryColor,
      child: ListView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        children: <Widget>[
          CardWithChildren(
            title: 'Aparência e Sentimento',
            children: <Widget>[
              CustomListTile(
                title: 'Tema',
                icon: FontAwesomeIcons.palette,
                subtitle: 'Seleciona a forma com que o app pareça.',
                onTap: () {
                  showThemeChangerDialog(context);
                },
              ),
            ],
          ),
          CardWithChildren(
            title: 'Coisas de Nerd',
            children: <Widget>[
              CustomListTile(
                title: 'Limpar o Cache',
                icon: Icons.memory,
                subtitle: 'Tamanho Total do Cache : $cacheSize',
                onTap: () async {
                  if (await showConfirmationDialog(context, 'Tem certeza?',
                      'Você tem certeza que deseja limpar o cache?')) {
                    clearCache();
                  }
                },
              ),
            ],
          ),
          _supportDev(state),
        ],
      ),
    );
  }

  Widget _supportDev(ThemeData theme) {
    return CardWithChildren(
      title: 'Apoiar ao Desenvolvimento',
      children: <Widget>[
        CustomListTile(
          icon: Icons.share,
          title: 'Compartilhar',
          subtitle: 'Compartilhe este app com seus amigos.',
          onTap: () => Share.share(appUrl),
        ),
        CustomListTile(
          icon: Icons.star,
          title: 'Avaliar o app',
          subtitle: 'Avalie o app na Play Store.',
          onTap: () => _launchURL(appUrl),
        ),
        CustomListTile(
          icon: FontAwesomeIcons.bug,
          title: 'Reportar um erro.',
          onTap: () => _launchURL(issuesUrl),
        ),
      ],
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class CustomListTile extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;

  CustomListTile(
      {Key key,
      this.title = 'Title',
      this.subtitle,
      this.icon = Icons.star,
      this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final ThemeData state = themeNotifier.getTheme();

    return ListTile(
      onTap: onTap,
      dense: true,
      leading: Icon(
        icon,
        color: Color(0xff909090),
      ),
      title: Text(
        title,
        style: state.textTheme.bodyText1,
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: state.textTheme.caption,
            ),
    );
  }
}
