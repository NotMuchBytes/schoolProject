# VOICE SCRIPT — CHAPTER 2

Frozen from the current implemented Arabic subtitles in `res://data/lesson2_dialogue.json`.

- Future recording root: `res://audio/final_voice_lesson2/`
- Runtime status: subtitle-only; no Chapter 2 MP3 files are required or preloaded.
- Player: silent protagonist. The current Chapter 2 subtitle source contains **0 player lines**, so no player filename is assigned.
- Scope: only lines routed through the Chapter 2 dialogue, cinematic, or authored ambient subtitle systems are recordings. HUD objectives, counters, hover labels, and correct/wrong UI notices are visual interface text and are not voice lines.

## SUMMARY TABLE

| Character | Speaker ID | Number of lines | First filename | Last filename | Suggested voice style |
|---|---|---:|---|---|---|
| الراوي | `l2_narrator` | 4 | `narrator_l2_001.mp3` | `narrator_l2_004.mp3` | راوٍ عربي واضح ومتزن؛ تعليمي وتأملي بلا مبالغة درامية |
| دليل المدينة | `l2_guide` | 2 | `city_guide_001.mp3` | `city_guide_002.mp3` | دليل بالغ ودود وواثق؛ ترحيبي وواضح |
| دليل الساحة | `l2_civic_guide` | 4 | `civic_guide_001.mp3` | `civic_guide_004.mp3` | مسؤول مدني هادئ؛ دقيق وشارح |
| المزارع | `l2_farmer` | 3 | `farmer_001.mp3` | `farmer_003.mp3` | مزارع بالغ عملي ودافئ؛ حديث طبيعي |
| الحرفي | `l2_artisan` | 3 | `artisan_001.mp3` | `artisan_003.mp3` | حرفي متمرس؛ فخور بعمله وعملي |
| التاجر | `l2_merchant` | 3 | `merchant_001.mp3` | `merchant_003.mp3` | تاجر نشيط وواضح؛ ودود وغير مبالغ |
| كاتب السجل | `l2_scribe` | 5 | `scribe_001.mp3` | `scribe_005.mp3` | كاتب سجل متزن؛ رسمي قليلاً ودقيق |
| دليل المعبد | `l2_temple_guide` | 3 | `temple_guide_001.mp3` | `temple_guide_003.mp3` | دليل معبد هادئ ومحترم؛ تاريخي ومحايد |
| مشرف المسرح | `l2_theatre_director` | 4 | `theatre_director_001.mp3` | `theatre_director_004.mp3` | مشرف مسرح معبّر وواضح؛ حيوي من دون تهويل |
| ممثل التراجيديا | `l2_tragedy_actor` | 1 | `tragedy_actor_001.mp3` | `tragedy_actor_001.mp3` | ممثل مسرحي حزين ومقروء؛ أداء قصير مضبوط |
| ممثل الكوميديا | `l2_comedy_actor` | 1 | `comedy_actor_001.mp3` | `comedy_actor_001.mp3` | ممثل مسرحي مرح وخفيف؛ نهاية سعيدة واضحة |
| دليل المكتبة | `l2_library_guide` | 5 | `library_guide_001.mp3` | `library_guide_005.mp3` | دليل مكتبة مثقف وهادئ؛ دقيق وسلس |
| البنّاء | `l2_architect` | 4 | `architect_001.mp3` | `architect_004.mp3` | بنّاء خبير؛ عملي وواضح مع ثقة هادئة |
| المدرب | `l2_coach` | 3 | `coach_001.mp3` | `coach_003.mp3` | مدرب رياضي مشجع وحازم؛ طاقة مضبوطة |
| دليل الآثار | `l2_jordan_guide` | 7 | `jordan_guide_001.mp3` | `jordan_guide_007.mp3` | دليل آثار أردني واضح ومحترم؛ وثائقي ودافئ |
| عامل المزرعة | `l2_farm_worker` | 1 | `ambient_l2_001.mp3` | `ambient_l2_001.mp3` | عامل منشغل؛ جملة محيطية طبيعية وقصيرة |
| حامل بضائع السوق | `l2_market_carrier` | 1 | `ambient_l2_002.mp3` | `ambient_l2_002.mp3` | عامل سوق أثناء العمل؛ طبيعي وغير موجه للاعب |
| عامل المرفأ | `l2_harbour_worker` | 1 | `ambient_l2_003.mp3` | `ambient_l2_003.mp3` | عامل مرفأ عملي؛ نداء قصير من البيئة |
| عضو الجوقة | `l2_theatre_chorus` | 1 | `ambient_l2_004.mp3` | `ambient_l2_004.mp3` | عضو جوقة يتحدث إلى زميل؛ سؤال طبيعي واضح |
| عامل خشبة المسرح | `l2_theatre_stagehand` | 1 | `ambient_l2_005.mp3` | `ambient_l2_005.mp3` | عامل مسرح يجيب زميله؛ هادئ ومستعد |
| طالب المكتبة | `l2_library_student` | 1 | `ambient_l2_006.mp3` | `ambient_l2_006.mp3` | طالب يراجع المعروض؛ هادئ وطبيعي |

Total extracted subtitle/voice lines: **58**.

## IMPORTANT CHAPTER 2 NPCS

### دليل المدينة

speaker_id: `l2_guide`  
suggested_voice_style: دليل بالغ ودود وواثق؛ ترحيبي وواضح

#### city_guide_001.mp3

- `filename`: `city_guide_001.mp3`
- `speaker_id`: `l2_guide`
- `dialogue_id`: `l2_intro_003`
- `text`: "ساعدني في إعداد سجل الحياة العامة. سنبدأ بالساحة، ثم نتتبع أعمال الناس وفنونهم."
- `audio_path`: `res://audio/final_voice_lesson2/city_guide/city_guide_001.mp3`
- `context`: الانتقال من الفصل الأول وفتح سجل الدرس الثاني
- `delivery`: دليل بالغ ودود وواثق؛ ترحيبي وواضح

#### city_guide_002.mp3

- `filename`: `city_guide_002.mp3`
- `speaker_id`: `l2_guide`
- `dialogue_id`: `l2_ending_001`
- `text`: "اكتمل سجل الحياة: الحكم والعمل والمجتمع والمعتقدات والفنون والرياضة، ثم الآثار في الأردن."
- `audio_path`: `res://audio/final_voice_lesson2/city_guide/city_guide_002.mp3`
- `context`: اكتمال سجل الحياة ونهاية الفصل الثاني
- `delivery`: دليل بالغ ودود وواثق؛ ترحيبي وواضح

### دليل الساحة

speaker_id: `l2_civic_guide`  
suggested_voice_style: مسؤول مدني هادئ؛ دقيق وشارح

#### civic_guide_001.mp3

- `filename`: `civic_guide_001.mp3`
- `speaker_id`: `l2_civic_guide`
- `dialogue_id`: `l2_politics_001`
- `text`: "لم يبق الحكم على صورة واحدة. كانت معظم المدن تحكم بنظام ملكي، وكان الملك يمثل السلطة العليا."
- `audio_path`: `res://audio/final_voice_lesson2/civic_guide/civic_guide_001.mp3`
- `context`: الساحة العامة — أنظمة الحكم
- `delivery`: مسؤول مدني هادئ؛ دقيق وشارح

#### civic_guide_002.mp3

- `filename`: `civic_guide_002.mp3`
- `speaker_id`: `l2_civic_guide`
- `dialogue_id`: `l2_politics_002`
- `text`: "ثم ظهرت أنظمة أخرى: الديمقراطية في أثينا، والحكم العسكري الصارم في إسبرطة، والحكم الاستبدادي في بعض المدن."
- `audio_path`: `res://audio/final_voice_lesson2/civic_guide/civic_guide_002.mp3`
- `context`: الساحة العامة — أنظمة الحكم
- `delivery`: مسؤول مدني هادئ؛ دقيق وشارح

#### civic_guide_003.mp3

- `filename`: `civic_guide_003.mp3`
- `speaker_id`: `l2_civic_guide`
- `dialogue_id`: `l2_politics_003`
- `text`: "رتب بطاقات الأنظمة في السجل، ثم قارن من يتولى الحكم في كل وصف."
- `audio_path`: `res://audio/final_voice_lesson2/civic_guide/civic_guide_003.mp3`
- `context`: الساحة العامة — أنظمة الحكم
- `delivery`: مسؤول مدني هادئ؛ دقيق وشارح

#### civic_guide_004.mp3

- `filename`: `civic_guide_004.mp3`
- `speaker_id`: `l2_civic_guide`
- `dialogue_id`: `l2_politics_004`
- `text`: "عكست هذه الأنظمة تطور الفكر السياسي والاجتماعي، وأثرت في النظم التي تلتها."
- `audio_path`: `res://audio/final_voice_lesson2/civic_guide/civic_guide_004.mp3`
- `context`: الساحة العامة — أنظمة الحكم
- `delivery`: مسؤول مدني هادئ؛ دقيق وشارح

### المزارع

speaker_id: `l2_farmer`  
suggested_voice_style: مزارع بالغ عملي ودافئ؛ حديث طبيعي

#### farmer_001.mp3

- `filename`: `farmer_001.mp3`
- `speaker_id`: `l2_farmer`
- `dialogue_id`: `l2_farm_001`
- `text`: "هذه حبوب وزيتون وعنب. يذكر الدرس أن التربة الخصبة والمياه والمناخ المعتدل ساعدت على زراعتها."
- `audio_path`: `res://audio/final_voice_lesson2/farmer/farmer_001.mp3`
- `context`: منطقة الزراعة — المحاصيل والمعالجة
- `delivery`: مزارع بالغ عملي ودافئ؛ حديث طبيعي

#### farmer_002.mp3

- `filename`: `farmer_002.mp3`
- `speaker_id`: `l2_farmer`
- `dialogue_id`: `l2_farm_002`
- `text`: "وهناك مطاحن للحبوب ومعاصر للزيتون. واهتم الناس أيضاً بتربية الأغنام والأبقار."
- `audio_path`: `res://audio/final_voice_lesson2/farmer/farmer_002.mp3`
- `context`: منطقة الزراعة — المحاصيل والمعالجة
- `delivery`: مزارع بالغ عملي ودافئ؛ حديث طبيعي

#### farmer_003.mp3

- `filename`: `farmer_003.mp3`
- `speaker_id`: `l2_farmer`
- `dialogue_id`: `l2_farm_003`
- `text`: "تأمل المنتجات الثلاثة، ثم اتبعها إلى الورشة والسوق."
- `audio_path`: `res://audio/final_voice_lesson2/farmer/farmer_003.mp3`
- `context`: منطقة الزراعة — المحاصيل والمعالجة
- `delivery`: مزارع بالغ عملي ودافئ؛ حديث طبيعي

### الحرفي

speaker_id: `l2_artisan`  
suggested_voice_style: حرفي متمرس؛ فخور بعمله وعملي

#### artisan_001.mp3

- `filename`: `artisan_001.mp3`
- `speaker_id`: `l2_artisan`
- `dialogue_id`: `l2_workshop_001`
- `text`: "ازدهرت الحرف مع توافر المعادن والأخشاب وانتشار الأسواق، ومع التنافس الصناعي مع حضارات مجاورة كالفينيقية."
- `audio_path`: `res://audio/final_voice_lesson2/artisan/artisan_001.mp3`
- `context`: الورشة — الصناعة والمواد
- `delivery`: حرفي متمرس؛ فخور بعمله وعملي

#### artisan_002.mp3

- `filename`: `artisan_002.mp3`
- `speaker_id`: `l2_artisan`
- `dialogue_id`: `l2_workshop_002`
- `text`: "صنع اليونانيون الأسلحة والحلي والسفن والأدوات الزراعية والأواني والفخار."
- `audio_path`: `res://audio/final_voice_lesson2/artisan/artisan_002.mp3`
- `context`: الورشة — الصناعة والمواد
- `delivery`: حرفي متمرس؛ فخور بعمله وعملي

#### artisan_003.mp3

- `filename`: `artisan_003.mp3`
- `speaker_id`: `l2_artisan`
- `dialogue_id`: `l2_workshop_003`
- `text`: "اختر منتجاً من المعروضات وافحص مادته. لا تحتاج إلى صنع سلاح أو خوض قتال."
- `audio_path`: `res://audio/final_voice_lesson2/artisan/artisan_003.mp3`
- `context`: الورشة — الصناعة والمواد
- `delivery`: حرفي متمرس؛ فخور بعمله وعملي

### التاجر

speaker_id: `l2_merchant`  
suggested_voice_style: تاجر نشيط وواضح؛ ودود وغير مبالغ

#### merchant_001.mp3

- `filename`: `merchant_001.mp3`
- `speaker_id`: `l2_merchant`
- `dialogue_id`: `l2_trade_001`
- `text`: "السوق والمنتجات المحلية ينشطان التجارة الداخلية. أما البحر فيفتح طريق التجارة الخارجية."
- `audio_path`: `res://audio/final_voice_lesson2/merchant/merchant_001.mp3`
- `context`: السوق والمرفأ — التجارة الداخلية والخارجية
- `delivery`: تاجر نشيط وواضح؛ ودود وغير مبالغ

#### merchant_002.mp3

- `filename`: `merchant_002.mp3`
- `speaker_id`: `l2_merchant`
- `dialogue_id`: `l2_trade_002`
- `text`: "اتصل اليونان بحضارات أخرى، وشكلت مستعمراتهم أسواقاً ومراكز لشحن البضائع."
- `audio_path`: `res://audio/final_voice_lesson2/merchant/merchant_002.mp3`
- `context`: السوق والمرفأ — التجارة الداخلية والخارجية
- `delivery`: تاجر نشيط وواضح؛ ودود وغير مبالغ

#### merchant_003.mp3

- `filename`: `merchant_003.mp3`
- `speaker_id`: `l2_merchant`
- `dialogue_id`: `l2_trade_003`
- `text`: "ضع بطاقة السوق عند وجهة التجارة الداخلية، وبطاقة المرفأ عند وجهة التجارة الخارجية."
- `audio_path`: `res://audio/final_voice_lesson2/merchant/merchant_003.mp3`
- `context`: السوق والمرفأ — التجارة الداخلية والخارجية
- `delivery`: تاجر نشيط وواضح؛ ودود وغير مبالغ

### كاتب السجل

speaker_id: `l2_scribe`  
suggested_voice_style: كاتب سجل متزن؛ رسمي قليلاً ودقيق

#### scribe_001.mp3

- `filename`: `scribe_001.mp3`
- `speaker_id`: `l2_scribe`
- `dialogue_id`: `l2_society_001`
- `text`: "من القبيلة، ومع الاستقرار وتطور الحياة، ظهرت القرية ثم توسعت إلى مدن."
- `audio_path`: `res://audio/final_voice_lesson2/scribe/scribe_001.mp3`
- `context`: فناء السجل — طبقات المجتمع والحقوق
- `delivery`: كاتب سجل متزن؛ رسمي قليلاً ودقيق

#### scribe_002.mp3

- `filename`: `scribe_002.mp3`
- `speaker_id`: `l2_scribe`
- `dialogue_id`: `l2_society_002`
- `text`: "يعرض الدرس أربع طبقات: الحاكمة، ثم التجار والأثرياء، ثم العامة، ثم العبيد."
- `audio_path`: `res://audio/final_voice_lesson2/scribe/scribe_002.mp3`
- `context`: فناء السجل — طبقات المجتمع والحقوق
- `delivery`: كاتب سجل متزن؛ رسمي قليلاً ودقيق

#### scribe_003.mp3

- `filename`: `scribe_003.mp3`
- `speaker_id`: `l2_scribe`
- `dialogue_id`: `l2_society_003`
- `text`: "ووفق وصف الدرس، تمتعت الطبقات الثلاث الأولى بحقوق المواطنة، وحرم العبيد من هذه الحقوق."
- `audio_path`: `res://audio/final_voice_lesson2/scribe/scribe_003.mp3`
- `context`: فناء السجل — طبقات المجتمع والحقوق
- `delivery`: كاتب سجل متزن؛ رسمي قليلاً ودقيق

#### scribe_004.mp3

- `filename`: `scribe_004.mp3`
- `speaker_id`: `l2_scribe`
- `dialogue_id`: `l2_society_004`
- `text`: "ويذكر الدرس للمرأة حق امتلاك الأراضي، وحق الميراث، وحق التعليم."
- `audio_path`: `res://audio/final_voice_lesson2/scribe/scribe_004.mp3`
- `context`: فناء السجل — طبقات المجتمع والحقوق
- `delivery`: كاتب سجل متزن؛ رسمي قليلاً ودقيق

#### scribe_005.mp3

- `filename`: `scribe_005.mp3`
- `speaker_id`: `l2_scribe`
- `dialogue_id`: `l2_society_005`
- `text`: "رتب بطاقات الطبقات كما يعرضها الشكل في السجل. نحن نصف هذا المجتمع، ولا نقر حرمان الناس من حقوقهم."
- `audio_path`: `res://audio/final_voice_lesson2/scribe/scribe_005.mp3`
- `context`: فناء السجل — طبقات المجتمع والحقوق
- `delivery`: كاتب سجل متزن؛ رسمي قليلاً ودقيق

### دليل المعبد

speaker_id: `l2_temple_guide`  
suggested_voice_style: دليل معبد هادئ ومحترم؛ تاريخي ومحايد

#### temple_guide_001.mp3

- `filename`: `temple_guide_001.mp3`
- `speaker_id`: `l2_temple_guide`
- `dialogue_id`: `l2_religion_001`
- `text`: "اعتقد اليونان أن آلهة معينة تتحكم في قوى الطبيعة؛ فصوروها في صور وتماثيل وبنوا لها المعابد."
- `audio_path`: `res://audio/final_voice_lesson2/temple_guide/temple_guide_001.mp3`
- `context`: المعبد — المعتقدات اليونانية
- `delivery`: دليل معبد هادئ ومحترم؛ تاريخي ومحايد

#### temple_guide_002.mp3

- `filename`: `temple_guide_002.mp3`
- `speaker_id`: `l2_temple_guide`
- `dialogue_id`: `l2_religion_002`
- `text`: "يذكر الدرس زيوس كبير الآلهة، وأبولو إله الشمس، وأثينا آلهة الحكمة."
- `audio_path`: `res://audio/final_voice_lesson2/temple_guide/temple_guide_002.mp3`
- `context`: المعبد — المعتقدات اليونانية
- `delivery`: دليل معبد هادئ ومحترم؛ تاريخي ومحايد

#### temple_guide_003.mp3

- `filename`: `temple_guide_003.mp3`
- `speaker_id`: `l2_temple_guide`
- `dialogue_id`: `l2_religion_003`
- `text`: "نحن نتعرف إلى معتقداتهم وآثارها في حياتهم. تأمل المعروضات ثم تابع إلى المسرح."
- `audio_path`: `res://audio/final_voice_lesson2/temple_guide/temple_guide_003.mp3`
- `context`: المعبد — المعتقدات اليونانية
- `delivery`: دليل معبد هادئ ومحترم؛ تاريخي ومحايد

### مشرف المسرح

speaker_id: `l2_theatre_director`  
suggested_voice_style: مشرف مسرح معبّر وواضح؛ حيوي من دون تهويل

#### theatre_director_001.mp3

- `filename`: `theatre_director_001.mp3`
- `speaker_id`: `l2_theatre_director`
- `dialogue_id`: `l2_theatre_001`
- `text`: "ارتبط المسرح بالاحتفالات والطقوس لشكر الآلهة على الإنتاج الوفير أو التوسل إليها في سنوات القحط."
- `audio_path`: `res://audio/final_voice_lesson2/theatre_director/theatre_director_001.mp3`
- `context`: المسرح — شرح العرض ونشاطه
- `delivery`: مشرف مسرح معبّر وواضح؛ حيوي من دون تهويل

#### theatre_director_002.mp3

- `filename`: `theatre_director_002.mp3`
- `speaker_id`: `l2_theatre_director`
- `dialogue_id`: `l2_theatre_002`
- `text`: "التراجيديا تنتهي بنهاية حزينة، والكوميديا تنتهي بنهاية سعيدة."
- `audio_path`: `res://audio/final_voice_lesson2/theatre_director/theatre_director_002.mp3`
- `context`: المسرح — شرح العرض ونشاطه
- `delivery`: مشرف مسرح معبّر وواضح؛ حيوي من دون تهويل

#### theatre_director_003.mp3

- `filename`: `theatre_director_003.mp3`
- `speaker_id`: `l2_theatre_director`
- `dialogue_id`: `l2_theatre_003`
- `text`: "تعرّف إلى الجوقة والأوركسترا وخشبة المسرح والممثلين، ثم شاهد نهايتين قصيرتين."
- `audio_path`: `res://audio/final_voice_lesson2/theatre_director/theatre_director_003.mp3`
- `context`: المسرح — شرح العرض ونشاطه
- `delivery`: مشرف مسرح معبّر وواضح؛ حيوي من دون تهويل

#### theatre_director_004.mp3

- `filename`: `theatre_director_004.mp3`
- `speaker_id`: `l2_theatre_director`
- `dialogue_id`: `l2_theatre_004`
- `text`: "أي النهايتين حزينة وأيهما سعيدة؟ سجّل الفرق، لا تحفظ حكاية الممثل؛ فهي مثال تمثيلي."
- `audio_path`: `res://audio/final_voice_lesson2/theatre_director/theatre_director_004.mp3`
- `context`: المسرح — شرح العرض ونشاطه
- `delivery`: مشرف مسرح معبّر وواضح؛ حيوي من دون تهويل

### ممثل التراجيديا

speaker_id: `l2_tragedy_actor`  
suggested_voice_style: ممثل مسرحي حزين ومقروء؛ أداء قصير مضبوط

#### tragedy_actor_001.mp3

- `filename`: `tragedy_actor_001.mp3`
- `speaker_id`: `l2_tragedy_actor`
- `dialogue_id`: `l2_stage_tragedy_001`
- `text`: "بحثت عن صاحبي عند المرفأ، لكن السفينة رحلت، وبقيت وحدي."
- `audio_path`: `res://audio/final_voice_lesson2/tragedy_actor/tragedy_actor_001.mp3`
- `context`: بروفة المسرح — المثال التراجيدي
- `delivery`: ممثل مسرحي حزين ومقروء؛ أداء قصير مضبوط

### ممثل الكوميديا

speaker_id: `l2_comedy_actor`  
suggested_voice_style: ممثل مسرحي مرح وخفيف؛ نهاية سعيدة واضحة

#### comedy_actor_001.mp3

- `filename`: `comedy_actor_001.mp3`
- `speaker_id`: `l2_comedy_actor`
- `dialogue_id`: `l2_stage_comedy_001`
- `text`: "ظننت أن صاحبي رحل، فإذا به خلفي يحمل السلة! سنعود معاً."
- `audio_path`: `res://audio/final_voice_lesson2/comedy_actor/comedy_actor_001.mp3`
- `context`: بروفة المسرح — المثال الكوميدي
- `delivery`: ممثل مسرحي مرح وخفيف؛ نهاية سعيدة واضحة

### دليل المكتبة

speaker_id: `l2_library_guide`  
suggested_voice_style: دليل مكتبة مثقف وهادئ؛ دقيق وسلس

#### library_guide_001.mp3

- `filename`: `library_guide_001.mp3`
- `speaker_id`: `l2_library_guide`
- `dialogue_id`: `l2_ideas_001`
- `text`: "أفلاطون مؤسس الفلسفة المثالية، ومن كتبه الجمهورية والقوانين."
- `audio_path`: `res://audio/final_voice_lesson2/library_guide/library_guide_001.mp3`
- `context`: المكتبة — الفلسفة وكتابة التاريخ
- `delivery`: دليل مكتبة مثقف وهادئ؛ دقيق وسلس

#### library_guide_002.mp3

- `filename`: `library_guide_002.mp3`
- `speaker_id`: `l2_library_guide`
- `dialogue_id`: `l2_ideas_002`
- `text`: "وأرسطو تلميذ أفلاطون ومعلم الإسكندر. يصفه الدرس بمؤسس الفلسفة الواقعية، ويذكر استخدامه المنهج العلمي."
- `audio_path`: `res://audio/final_voice_lesson2/library_guide/library_guide_002.mp3`
- `context`: المكتبة — الفلسفة وكتابة التاريخ
- `delivery`: دليل مكتبة مثقف وهادئ؛ دقيق وسلس

#### library_guide_003.mp3

- `filename`: `library_guide_003.mp3`
- `speaker_id`: `l2_library_guide`
- `dialogue_id`: `l2_ideas_003`
- `text`: "ومن كتب أرسطو السياسة، وفيه ناقش أنواع الحكومات."
- `audio_path`: `res://audio/final_voice_lesson2/library_guide/library_guide_003.mp3`
- `context`: المكتبة — الفلسفة وكتابة التاريخ
- `delivery`: دليل مكتبة مثقف وهادئ؛ دقيق وسلس

#### library_guide_004.mp3

- `filename`: `library_guide_004.mp3`
- `speaker_id`: `l2_library_guide`
- `dialogue_id`: `l2_ideas_004`
- `text`: "أما هيرودوت فلقب بأبي التاريخ؛ ويذكر الدرس اعتماده على الأساطير الدينية وكتابته عن اليونان والفرس وغيرهم."
- `audio_path`: `res://audio/final_voice_lesson2/library_guide/library_guide_004.mp3`
- `context`: المكتبة — الفلسفة وكتابة التاريخ
- `delivery`: دليل مكتبة مثقف وهادئ؛ دقيق وسلس

#### library_guide_005.mp3

- `filename`: `library_guide_005.mp3`
- `speaker_id`: `l2_library_guide`
- `dialogue_id`: `l2_ideas_005`
- `text`: "ضع كل بطاقة مؤلف بجانب العمل أو الوصف الذي يخصه في المعرض."
- `audio_path`: `res://audio/final_voice_lesson2/library_guide/library_guide_005.mp3`
- `context`: المكتبة — الفلسفة وكتابة التاريخ
- `delivery`: دليل مكتبة مثقف وهادئ؛ دقيق وسلس

### البنّاء

speaker_id: `l2_architect`  
suggested_voice_style: بنّاء خبير؛ عملي وواضح مع ثقة هادئة

#### architect_001.mp3

- `filename`: `architect_001.mp3`
- `speaker_id`: `l2_architect`
- `dialogue_id`: `l2_architecture_001`
- `text`: "تصف صفحة العمارة مدينة محاطة بالأسوار، وفي مركزها ساحة عامة فيها المعبد والمسرح، وأبنيتها موزعة بانتظام."
- `audio_path`: `res://audio/final_voice_lesson2/architect/architect_001.mp3`
- `context`: منصة المشاهدة — العمارة والنحت
- `delivery`: بنّاء خبير؛ عملي وواضح مع ثقة هادئة

#### architect_002.mp3

- `filename`: `architect_002.mp3`
- `speaker_id`: `l2_architect`
- `dialogue_id`: `l2_architecture_002`
- `text`: "ساعد توافر الرخام على العمارة، واستخدم النحاتون الرخام والبرونز."
- `audio_path`: `res://audio/final_voice_lesson2/architect/architect_002.mp3`
- `context`: منصة المشاهدة — العمارة والنحت
- `delivery`: بنّاء خبير؛ عملي وواضح مع ثقة هادئة

#### architect_003.mp3

- `filename`: `architect_003.mp3`
- `speaker_id`: `l2_architect`
- `dialogue_id`: `l2_architecture_003`
- `text`: "شملت المنحوتات الآلهة وكبار القادة والشخصيات العسكرية."
- `audio_path`: `res://audio/final_voice_lesson2/architect/architect_003.mp3`
- `context`: منصة المشاهدة — العمارة والنحت
- `delivery`: بنّاء خبير؛ عملي وواضح مع ثقة هادئة

#### architect_004.mp3

- `filename`: `architect_004.mp3`
- `speaker_id`: `l2_architect`
- `dialogue_id`: `l2_architecture_004`
- `text`: "من هذه الشرفة، حدد السور والساحة والمسرح في المدينة التي زرتها."
- `audio_path`: `res://audio/final_voice_lesson2/architect/architect_004.mp3`
- `context`: منصة المشاهدة — العمارة والنحت
- `delivery`: بنّاء خبير؛ عملي وواضح مع ثقة هادئة

### المدرب

speaker_id: `l2_coach`  
suggested_voice_style: مدرب رياضي مشجع وحازم؛ طاقة مضبوطة

#### coach_001.mp3

- `filename`: `coach_001.mp3`
- `speaker_id`: `l2_coach`
- `dialogue_id`: `l2_sport_001`
- `text`: "اهتم اليونانيون بالمصارعة والسباحة وركوب الخيل والجري والصيد، وكانت أثينا مركزاً للألعاب والتمارين."
- `audio_path`: `res://audio/final_voice_lesson2/coach/coach_001.mp3`
- `context`: ساحة الرياضة — نشاط الجري القصير
- `delivery`: مدرب رياضي مشجع وحازم؛ طاقة مضبوطة

#### coach_002.mp3

- `filename`: `coach_002.mp3`
- `speaker_id`: `l2_coach`
- `dialogue_id`: `l2_sport_002`
- `text`: "يذكر الدرس الهوكي والجمباز أيضاً، والمباريات الجماعية والفردية، وحضور الناس للمشاهدة والتشجيع."
- `audio_path`: `res://audio/final_voice_lesson2/coach/coach_002.mp3`
- `context`: ساحة الرياضة — نشاط الجري القصير
- `delivery`: مدرب رياضي مشجع وحازم؛ طاقة مضبوطة

#### coach_003.mp3

- `filename`: `coach_003.mp3`
- `speaker_id`: `l2_coach`
- `dialogue_id`: `l2_sport_003`
- `text`: "وينسب الدرس إلى اليونانيين إقامة الألعاب الأولمبية. جرّب مسار الجري القصير أمامك؛ إنه تدريب داخل رحلتنا."
- `audio_path`: `res://audio/final_voice_lesson2/coach/coach_003.mp3`
- `context`: ساحة الرياضة — نشاط الجري القصير
- `delivery`: مدرب رياضي مشجع وحازم؛ طاقة مضبوطة

### دليل الآثار

speaker_id: `l2_jordan_guide`  
suggested_voice_style: دليل آثار أردني واضح ومحترم؛ وثائقي ودافئ

#### jordan_guide_001.mp3

- `filename`: `jordan_guide_001.mp3`
- `speaker_id`: `l2_jordan_guide`
- `dialogue_id`: `l2_jordan_002`
- `text`: "بعد وفاة الإسكندر، يذكر الدرس أن الأردن كان من نصيب بطليموس، مؤسس المملكة البطلمية وعاصمتها الإسكندرية."
- `audio_path`: `res://audio/final_voice_lesson2/jordan_guide/jordan_guide_001.mp3`
- `context`: سجل الأردن — المدن والآثار وقصر العبد
- `delivery`: دليل آثار أردني واضح ومحترم؛ وثائقي ودافئ

#### jordan_guide_002.mp3

- `filename`: `jordan_guide_002.mp3`
- `speaker_id`: `l2_jordan_guide`
- `dialogue_id`: `l2_jordan_003`
- `text`: "ويذكر احتلال ربة عمون، أي عمان، عام 300 قبل الميلاد، وتسميتها فيما بعد فيلادلفيا نسبة إلى بطليموس فيلادلفيوس."
- `audio_path`: `res://audio/final_voice_lesson2/jordan_guide/jordan_guide_002.mp3`
- `context`: سجل الأردن — المدن والآثار وقصر العبد
- `delivery`: دليل آثار أردني واضح ومحترم؛ وثائقي ودافئ

#### jordan_guide_003.mp3

- `filename`: `jordan_guide_003.mp3`
- `speaker_id`: `l2_jordan_guide`
- `dialogue_id`: `l2_jordan_004`
- `text`: "من المدن المذكورة: طبقة فحل، بيلا؛ وأم قيس، جادارا؛ وجرش، جراسا؛ وحسبان، حشبون."
- `audio_path`: `res://audio/final_voice_lesson2/jordan_guide/jordan_guide_003.mp3`
- `context`: سجل الأردن — المدن والآثار وقصر العبد
- `delivery`: دليل آثار أردني واضح ومحترم؛ وثائقي ودافئ

#### jordan_guide_004.mp3

- `filename`: `jordan_guide_004.mp3`
- `speaker_id`: `l2_jordan_guide`
- `dialogue_id`: `l2_jordan_005`
- `text`: "تسببت الحروب والكوارث الطبيعية في تدمير معظم الأبنية التي يتحدث عنها الدرس، ويبرز قصر عراق الأمير، أو قصر العبد."
- `audio_path`: `res://audio/final_voice_lesson2/jordan_guide/jordan_guide_004.mp3`
- `context`: سجل الأردن — المدن والآثار وقصر العبد
- `delivery`: دليل آثار أردني واضح ومحترم؛ وثائقي ودافئ

#### jordan_guide_005.mp3

- `filename`: `jordan_guide_005.mp3`
- `speaker_id`: `l2_jordan_guide`
- `dialogue_id`: `l2_jordan_006`
- `text`: "يؤرخ صندوق المعلومات قصر العبد بالعصر الهلنستي في القرن الثاني قبل الميلاد، ويحدد موقعه جنوب بلدة عراق الأمير، غرب عمان."
- `audio_path`: `res://audio/final_voice_lesson2/jordan_guide/jordan_guide_005.mp3`
- `context`: سجل الأردن — المدن والآثار وقصر العبد
- `delivery`: دليل آثار أردني واضح ومحترم؛ وثائقي ودافئ

#### jordan_guide_006.mp3

- `filename`: `jordan_guide_006.mp3`
- `speaker_id`: `l2_jordan_guide`
- `dialogue_id`: `l2_jordan_007`
- `text`: "ويختتم الدرس بضعف الدولة اليونانية بسبب الحروب، ثم الاحتلال الروماني لبلاد الشام بقيادة بومبيوس."
- `audio_path`: `res://audio/final_voice_lesson2/jordan_guide/jordan_guide_006.mp3`
- `context`: سجل الأردن — المدن والآثار وقصر العبد
- `delivery`: دليل آثار أردني واضح ومحترم؛ وثائقي ودافئ

#### jordan_guide_007.mp3

- `filename`: `jordan_guide_007.mp3`
- `speaker_id`: `l2_jordan_guide`
- `dialogue_id`: `l2_jordan_008`
- `text`: "طابق أسماء المدن في السجل، ثم افتح بطاقة القصر لتتعرف إلى موقعه وتأريخه."
- `audio_path`: `res://audio/final_voice_lesson2/jordan_guide/jordan_guide_007.mp3`
- `context`: سجل الأردن — المدن والآثار وقصر العبد
- `delivery`: دليل آثار أردني واضح ومحترم؛ وثائقي ودافئ

## NARRATOR CHAPTER 2

### الراوي

speaker_id: `l2_narrator`  
suggested_voice_style: راوٍ عربي واضح ومتزن؛ تعليمي وتأملي بلا مبالغة درامية

#### narrator_l2_001.mp3

- `filename`: `narrator_l2_001.mp3`
- `speaker_id`: `l2_narrator`
- `dialogue_id`: `l2_intro_001`
- `text`: "عرفتَ كيف نشأت المدن واتسعت الإمبراطوريات. والآن، لنفتح سجلاً آخر: كيف عاش الناس؟"
- `audio_path`: `res://audio/final_voice_lesson2/narrator/narrator_l2_001.mp3`
- `context`: الانتقال من الفصل الأول وفتح سجل الدرس الثاني
- `delivery`: راوٍ عربي واضح ومتزن؛ تعليمي وتأملي بلا مبالغة درامية

#### narrator_l2_002.mp3

- `filename`: `narrator_l2_002.mp3`
- `speaker_id`: `l2_narrator`
- `dialogue_id`: `l2_intro_002`
- `text`: "تجمع هذه الرحلة مشاهد من فترات مختلفة؛ إنها رحلة في السجل، وليست أحداث يوم واحد من التاريخ."
- `audio_path`: `res://audio/final_voice_lesson2/narrator/narrator_l2_002.mp3`
- `context`: الانتقال من الفصل الأول وفتح سجل الدرس الثاني
- `delivery`: راوٍ عربي واضح ومتزن؛ تعليمي وتأملي بلا مبالغة درامية

#### narrator_l2_003.mp3

- `filename`: `narrator_l2_003.mp3`
- `speaker_id`: `l2_narrator`
- `dialogue_id`: `l2_jordan_001`
- `text`: "لنفتح الآن صفحة الأردن من السجل. يربط الدرس خضوعه للحكم اليوناني بحملة الإسكندر على مصر وبلاد الشام عام 332 قبل الميلاد."
- `audio_path`: `res://audio/final_voice_lesson2/narrator/narrator_l2_003.mp3`
- `context`: سجل الأردن — المدن والآثار وقصر العبد
- `delivery`: راوٍ عربي واضح ومتزن؛ تعليمي وتأملي بلا مبالغة درامية

#### narrator_l2_004.mp3

- `filename`: `narrator_l2_004.mp3`
- `speaker_id`: `l2_narrator`
- `dialogue_id`: `l2_ending_002`
- `text`: "لم تكن الحضارة حدوداً وحروباً وحدها؛ كانت حياة ناس ومدناً وأعمالاً وأفكاراً."
- `audio_path`: `res://audio/final_voice_lesson2/narrator/narrator_l2_004.mp3`
- `context`: اكتمال سجل الحياة ونهاية الفصل الثاني
- `delivery`: راوٍ عربي واضح ومتزن؛ تعليمي وتأملي بلا مبالغة درامية

## AMBIENT CHAPTER 2

These are authored positional city lines. They are separate from mission dialogue.

### عامل المزرعة

speaker_id: `l2_farm_worker`  
suggested_voice_style: عامل منشغل؛ جملة محيطية طبيعية وقصيرة

#### ambient_l2_001.mp3

- `filename`: `ambient_l2_001.mp3`
- `speaker_id`: `l2_farm_worker`
- `dialogue_id`: `l2_ambient_001`
- `text`: "ضع الزيتون قرب المعصرة."
- `audio_path`: `res://audio/final_voice_lesson2/farm_worker/ambient_l2_001.mp3`
- `context`: حديث محيطي مؤلف داخل مدينة الفصل الثاني
- `delivery`: عامل منشغل؛ جملة محيطية طبيعية وقصيرة

### حامل بضائع السوق

speaker_id: `l2_market_carrier`  
suggested_voice_style: عامل سوق أثناء العمل؛ طبيعي وغير موجه للاعب

#### ambient_l2_002.mp3

- `filename`: `ambient_l2_002.mp3`
- `speaker_id`: `l2_market_carrier`
- `dialogue_id`: `l2_ambient_002`
- `text`: "هذه الأواني جاهزة للسوق."
- `audio_path`: `res://audio/final_voice_lesson2/market_carrier/ambient_l2_002.mp3`
- `context`: حديث محيطي مؤلف داخل مدينة الفصل الثاني
- `delivery`: عامل سوق أثناء العمل؛ طبيعي وغير موجه للاعب

### عامل المرفأ

speaker_id: `l2_harbour_worker`  
suggested_voice_style: عامل مرفأ عملي؛ نداء قصير من البيئة

#### ambient_l2_003.mp3

- `filename`: `ambient_l2_003.mp3`
- `speaker_id`: `l2_harbour_worker`
- `dialogue_id`: `l2_ambient_003`
- `text`: "البضائع عند المرفأ."
- `audio_path`: `res://audio/final_voice_lesson2/harbour_worker/ambient_l2_003.mp3`
- `context`: حديث محيطي مؤلف داخل مدينة الفصل الثاني
- `delivery`: عامل مرفأ عملي؛ نداء قصير من البيئة

### عضو الجوقة

speaker_id: `l2_theatre_chorus`  
suggested_voice_style: عضو جوقة يتحدث إلى زميل؛ سؤال طبيعي واضح

#### ambient_l2_004.mp3

- `filename`: `ambient_l2_004.mp3`
- `speaker_id`: `l2_theatre_chorus`
- `dialogue_id`: `l2_ambient_004`
- `text`: "هل استعدت الجوقة للمشهد؟"
- `audio_path`: `res://audio/final_voice_lesson2/theatre_chorus/ambient_l2_004.mp3`
- `context`: حديث محيطي مؤلف داخل مدينة الفصل الثاني
- `delivery`: عضو جوقة يتحدث إلى زميل؛ سؤال طبيعي واضح

### عامل خشبة المسرح

speaker_id: `l2_theatre_stagehand`  
suggested_voice_style: عامل مسرح يجيب زميله؛ هادئ ومستعد

#### ambient_l2_005.mp3

- `filename`: `ambient_l2_005.mp3`
- `speaker_id`: `l2_theatre_stagehand`
- `dialogue_id`: `l2_ambient_005`
- `text`: "ابدأ عندما تكون مستعداً."
- `audio_path`: `res://audio/final_voice_lesson2/theatre_stagehand/ambient_l2_005.mp3`
- `context`: حديث محيطي مؤلف داخل مدينة الفصل الثاني
- `delivery`: عامل مسرح يجيب زميله؛ هادئ ومستعد

### طالب المكتبة

speaker_id: `l2_library_student`  
suggested_voice_style: طالب يراجع المعروض؛ هادئ وطبيعي

#### ambient_l2_006.mp3

- `filename`: `ambient_l2_006.mp3`
- `speaker_id`: `l2_library_student`
- `dialogue_id`: `l2_ambient_006`
- `text`: "بطاقات المؤلفين على الطاولة."
- `audio_path`: `res://audio/final_voice_lesson2/library_student/ambient_l2_006.mp3`
- `context`: حديث محيطي مؤلف داخل مدينة الفصل الثاني
- `delivery`: طالب يراجع المعروض؛ هادئ وطبيعي

## EXACT TOTALS

- TOTAL IMPORTANT CHARACTERS: **14**
- TOTAL IMPORTANT NPC LINES: **46**
- TOTAL NARRATOR LINES: **4**
- TOTAL NPC-TO-NPC LINES: **2**
- TOTAL AMBIENT LINES: **6**
- GRAND TOTAL RECORDINGS: **58**

The total categories above are mutually exclusive and sum to the grand total. No player recording is included.
