import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// بطاقة نفحات قرآنية محفزة وتفاعلية
class QuranDailyVerseCard extends StatefulWidget {
  const QuranDailyVerseCard({super.key});

  @override
  State<QuranDailyVerseCard> createState() => _QuranDailyVerseCardState();
}

class _QuranDailyVerseCardState extends State<QuranDailyVerseCard> {
  int _currentIndex = 0;

  static const List<Map<String, String>> _inspirations = [
    {
      'type': 'حديث نبوي شريف',
      'text': '«خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ»',
      'source': 'صحيح البخاري',
      'benefit': 'أعظم المراتب وأرفع الدرجات عند الله هي في تعليم كتاب الله وتدارسه.',
    },
    {
      'type': 'بشرى نبوية',
      'text': '«إِنَّ لِلَّهِ أَهْلِينَ مِنَ النَّاسِ، قَالُوا: مَنْ هُمْ يَا رَسُولَ اللَّهِ؟ قَالَ: أَهْلُ الْقُرْآنِ هُمْ أَهْلُ اللَّهِ وَخَاصَّتُهُ»',
      'source': 'رواه أحمد والنسائي وابن ماجه',
      'benefit': 'طوبى لمن اصطفاهم الله لخدمة كتابه وحفظه وتعليمه في بيوته.',
    },
    {
      'type': 'كرامة يوم القيامة',
      'text': '«يُقَالُ لِصَاحِبِ الْقُرْآنِ: اقْرَأْ وَارْتَقِ وَرَتِّلْ كَمَا كُنْتَ تَرَتِّلُ فِي الدُّنْيَا، فَإِنَّ مَنْزِلَتَكَ عِنْدَ آخِرِ آيَةٍ تَقْرَؤُهَا»',
      'source': 'رواه أبو داود والترمذي وصححه',
      'benefit': 'كل آية يحفظها الطالب ترقيه درجة في أعالي الجنان.',
    },
    {
      'type': 'فضل التلاوة والمدارسة',
      'text': '«مَا اجْتَمَعَ قَوْمٌ فِي بَيْتٍ مِنْ بُيُوتِ اللَّهِ يَتْلُونَ كِتَابَ اللَّهِ وَيَتَدَارَسُونَهُ بَيْنَهُمْ، إِلَّا نَزَلَتْ عَلَيْهِمُ السَّكِينَةُ، وَغَشِيَتْهُمُ الرَّحْمَةُ، وَحَفَّتْهُمُ الْمَلَائِكَةُ»',
      'source': 'صحيح مسلم',
      'benefit': 'سكينة وبركة ورحمة تفيض على حلقات مسجد الريان ومدرسيها وطلابها.',
    },
    {
      'type': 'جزاء المعلم والمربي',
      'text': '«إِنَّ اللَّهَ وَمَلَائِكَتَهُ وَأَهْلَ السَّمَوَاتِ وَالأَرْضِ حَتَّى النَّمْلَةَ فِي جُحْرِهَا وَحَتَّى الحُوتَ لَيُصَلُّونَ عَلَى مُعَلِّمِ النَّاسِ الخَيْرَ»',
      'source': 'رواه الترمذي',
      'benefit': 'دعوات مباركة تحف كل حرف يُعلَّم لصغير أو كبير.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = Random().nextInt(_inspirations.length);
  }

  void _nextInspiration() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _inspirations.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = _inspirations[_currentIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(AppColors.primaryGreen).withAlpha(20),
            const Color(AppColors.goldDark).withAlpha(25),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(AppColors.goldSoft).withAlpha(120),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(AppColors.primaryGreen),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      item['type']!,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: _nextInspiration,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.refresh, size: 14, color: Color(AppColors.primaryGreenDark)),
                      const SizedBox(width: 4),
                      Text(
                        'نفحة جديدة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: const Color(AppColors.primaryGreenDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item['text']!,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(AppColors.primaryGreenDark),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['source']!,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                'مسجد الريان بتريم',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  color: const Color(AppColors.goldDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item['benefit']!,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
