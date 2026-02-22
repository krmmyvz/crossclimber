import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:crossclimber/services/ad_service.dart';

/// A self-contained banner ad widget.
///
/// Loads a banner ad on mount and disposes it on unmount.  Shows an empty
/// [SizedBox] while loading or if the ad fails.
class AdBannerWidget extends StatefulWidget {
  final AdSize adSize;

  const AdBannerWidget({super.key, this.adSize = AdSize.banner});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = AdService.instance.createBannerAd(
      size: widget.adSize,
      onAdLoaded: (_) {
        if (mounted) setState(() => _isAdLoaded = true);
      },
      onAdFailedToLoad: (_, __) {
        if (mounted) setState(() => _isAdLoaded = false);
      },
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return SizedBox(
        height: widget.adSize.height.toDouble(),
        width: double.infinity,
      );
    }

    return SizedBox(
      height: widget.adSize.height.toDouble(),
      width: widget.adSize.width == -1
          ? double.infinity
          : widget.adSize.width.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
