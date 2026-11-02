# -*- coding: utf-8 -*-
"""Generate asma_ul_husna.dart from SurahQuran ranking + user explanations."""
from __future__ import annotations

from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "lib" / "data" / "asma_ul_husna.dart"

# (index, arabic, translit, meaning_en, theme, explanation_ar)
PRIMARY: list[tuple[int, str, str, str, str, str]] = [
    (1, "الله", "Allah", "Allah", "oneness",
     "المألوه الواحد المعبود بحق الذي يفزع إليه العباد في الشدائد ويلجئون إليه في الحوائج، وتعبده الخلائق محبةً وتعظيماً وخضوعاً، فهو الخالق والمدبر لكل شيء في الكون الذي له صفات الألوهية والكمال والجلال والجمال، وهو عَلَمٌ على ذات الرب سبحانه وتعالى وهو أخص أسمائه لم يتسم به غيره {هَلْ تَعْلَمُ لَهُ سَمِيّاً}، وقيل: «هو الاسم الأعظم»."),
    (2, "الرحمن", "Ar-Rahman", "The Most Merciful", "mercy",
     "صاحب الرحمة الواسعة جل جلاله الذي وسعت رحمته كل مخلوقاته في الدنيا والآخرة، وهذا الاسم خاص بالله تعالى فلا يسمى به غيره سبحانه، وقد سميت بهذا الاسم سورة من سور القرآن الكريم وهي: سورة الرحمن، والدليل عليه قوله تعالى: ﴿الرَّحْمَٰنِ الرَّحِيمِ﴾."),
    (3, "الرحيم", "Ar-Raheem", "The Especially Merciful", "mercy",
     "الذي يرحم عباده المؤمنين ويتفضل بإحسانه على أوليائه وعباده الصالحين، ويختصهم برحمته وهدايته ويمن عليهم برضوانه: ﴿وَكَانَ بِالْمُؤْمِنِينَ رَحِيمًا﴾."),
    (4, "الملك", "Al-Malik", "The King", "majesty",
     "الذي له الملك الحقيقي الكامل التام الأزلي الذي لا ينقضي ولا يزول ولا يتغير ولا يحول فهو الملك الحق الذي ذلت له الرقاب وخضعت له السماوات والأرض ومن فيهن، يتصرف في ملكه كيف يشاء ويحكم فيه ما يريد."),
    (5, "القدوس", "Al-Quddoos", "The Pure", "majesty",
     "المنزه عن كل نقص والمطهر من كل عيب، الذي له كل صفات العظمة والكمال والجلال والجمال، الذي تنزه عن كل وصف لا يليق بجلاله."),
    (6, "السلام", "As-Salaam", "The Flawless / Source of Peace", "majesty",
     "السالم من كل عيب ونقص وآفة، المستغني عن جميع الخلق فهو الذي يعطي السلامة ويمنعها، وهو المنزه عن الخوف والضعف والذل، الذي يمن على عباده المؤمنين بالأمن يوم القيامة."),
    (7, "المؤمن", "Al-Mu'min", "The Granter of Security", "protection",
     "هو الذي أمن عبيده به سبحانه فلا يظلم عنده أحد، وأمن المؤمنون به من عذابه، فالأمن كله منه سبحانه وبه النجاة من كل خوف."),
    (8, "المهيمن", "Al-Muhaymin", "The Guardian", "protection",
     "المسيطر القادر الرقيب الشهيد الأمين على كل شيء، فكل شيء خاضع لسلطانه، وهو الذي يتولى ما في الكون من الحكم والتدبير وهو المحيط المراقب والمسيطر على كل حركة وسكنة في الوجود."),
    (9, "العزيز", "Al-Azeez", "The Almighty", "power",
     "ذو العزة المطلقة والغلبة والقدرة، وصاحب القوة والمنعة والسيادة والرفعة الغالب لكل من سواه، المذل لمن عاداه، القاهر لكل شيء الذي لا يعجزه شيء."),
    (10, "الجبار", "Al-Jabbaar", "The Compeller", "power",
     "صاحب الجبروت والعظمة القهار للعباد، والذي يتم أمره وفق ما أراد، وعلى عظمته يصلح أمور خلقه فيجبر الكسير ويغني الفقير وييسر العسير."),
    (11, "المتكبر", "Al-Mutakabbir", "The Supreme", "majesty",
     "ذو الكبرياء والعلو والعظمة، الكبير العظيم المتعالي عن صفات المخلوقين، القاهر لعتاة المجرمين، الذي تفرد بالألوهية والربوبية وذل لكبريائه كل من في السماوات والأرض."),
    (12, "الخالق", "Al-Khaaliq", "The Creator", "creation",
     "الذي أوجد كل شيء وأبدع كل موجود، وأنشأ كل ما في الكون وأخرجه من العدم إلى الوجود، وكوَّنه على غير مثال سابق بتقديره، فلا خالق حقيقة إلا هو."),
    (13, "البارئ", "Al-Baari'", "The Originator", "creation",
     "المحدث لكل ما سبق به علمه من الخلق، وواهب الحياة لكل حي، الذي أوجد كل ما في الكون من عدم ثم خلق منها أصنافا مختلفة على أحسن وأكمل صنعة."),
    (14, "المصور", "Al-Musawwir", "The Fashioner", "creation",
     "خالق صور الأشياء وموجدها على صورها التي صورها بها، الذي أنشأ الخلق متناسقا مركبا بصور مختلفة متباينة، وبدأ خلق الإنسان من طين وجعله في أفضل صورة."),
    (15, "الأول", "Al-Awwal", "The First", "oneness",
     "القديم بلا ابتداء الذي ليس قبله شيء، ولا يسبقه شيء، كان هو ولم يكن أي شيء موجودا قبله."),
    (16, "الآخر", "Al-Aakhir", "The Last", "oneness",
     "الذي ليس بعده شيء، والباقي بلا انتهاء إذا فني كل شيء، وإليه يرجع كل شيء وإليه تنتهي كل شؤون خلقه."),
    (17, "الظاهر", "Az-Zaahir", "The Manifest", "majesty",
     "الذي ليس فوقه شيء، العالي فوق كل شيء فلا شيء أعلى منه، الغالب الذي لا يقهره شيء، الذي ظهرت آيات قدرته في كل ما في الوجود."),
    (18, "الباطن", "Al-Baatin", "The Hidden", "knowledge",
     "الذي ليس دونه شيء، العالم ببواطن الأمور، المحتجب عن خلقه، والمطلع على الضمائر والسرائر فليس دونه ما يحجبه عن إدراك أي شيء من خلقه."),
    (19, "المالك", "Al-Maalik", "The Owner", "majesty",
     "المتملك الحقيقي الذي يملك كل ما في الوجود، وله حق التصرف فيه كيف يشاء، وفي الحديث «لا مالك إلا الله»، والدليل قوله تعالى: ﴿مَالِكِ يَوْمِ الدِّينِ﴾."),
    (20, "المليك", "Al-Maleek", "The Sovereign", "majesty",
     "الملك العظيم القادر، صاحب الملك العزيز الواسع، الذي يملك كل شيء ولا يعجزه شيء وله كل شيء، فهو الملك المالك جل جلاله."),
    (21, "الهادي", "Al-Haadi", "The Guide", "mercy",
     "المرشد الذي يدل إلى الحق والإيمان ويبين لعباده سبيل الخير والنجاة ويوفقهم للهداية إليه رحمة بهم."),
    (22, "السميع", "As-Samee'", "The All-Hearing", "knowledge",
     "السامع لأصوات الخلق كلهم، الذي وسع سمعه كل شيء، وله السمع الكامل المطلق، فلا تختلط عليه الأصوات ولا تشغله دعوة عن دعوة."),
    (23, "البصير", "Al-Baseer", "The All-Seeing", "knowledge",
     "المبصر الذي يرى جميع ما في الوجود ولا تخفى عليه خافية، ولا يغيب عن بصره شيء مهما دق أو صغر وإن ظهر أو خفي."),
    (24, "الواسع", "Al-Waasi'", "The Vast", "provision",
     "الجواد واسع الغنى كثير العطاء الذي وسع جوده وفضله ورزقه جميع خلقه، ووسعت رحمته كل شيء، وهو المحيط بكل شيء علما."),
    (25, "المحيط", "Al-Muheet", "The All-Encompassing", "knowledge",
     "العظيم الذي أحاط علمه وإرادته بالأمور كلها، فلا يخفى عليه شيء ولا يغيب عن علمه وقدرته شيء."),
    (26, "علّام الغيوب", "Allaam al-Ghuyoob", "Knower of the Unseen", "knowledge",
     "العالم بالخفايا والمطلع على البواطن والنوايا الذي يعلم السر وأخفى، العليم بذات الصدور وبما كان وما يكون."),
    (27, "الشاكر", "Ash-Shaakir", "The Appreciative", "forgiveness",
     "الذي يرضى من عباده بالقليل ويكافئهم عليه بالكثير، فيثيب الشاكرين ويثني على عباده المؤمنين، ويجزي الحسنة بأضعافها."),
    (28, "البر", "Al-Barr", "The Kind Benefactor", "mercy",
     "اللطيف بعباده الرفيق بهم المحسن إليهم، الذي عم بره وإحسانه جميع خلقه فلم يبخل عليهم برزقه سبحانه."),
    (29, "التواب", "At-Tawwaab", "The Accepter of Repentance", "forgiveness",
     "المحسن الذي يتوب على عباده ويتجاوز عن سيئاتهم، فيغفر لهم ويعفو ويصفح عنهم، ويوفقهم إلى التوبة ويقبلها كلما تكررت."),
    (30, "الرؤوف", "Ar-Ra'oof", "The Compassionate", "mercy",
     "كثير الرأفة والرحمة والعطف على عباده، كامل الرعاية لهم، المترفق بهم والمشفق عليهم، فلا يكلفهم ما لا يطيقون."),
    (31, "الولي", "Al-Waliyy", "The Protecting Friend", "protection",
     "المحب لمن أطاعه، الناصر لعباده وحافظهم والمعين لهم، والقائم على تدبير شؤونهم، فيرشدهم إلى ما ينفعهم في دنياهم وأخراهم."),
    (32, "المولى", "Al-Mawlaa", "The Patron", "protection",
     "السيد القائم بتدبير أمور جميع الكائنات وتصريف شؤونهم، فهو الملك وصاحب الولاية على الخلق ولا ولاية إلا به سبحانه."),
    (33, "الرب", "Ar-Rabb", "The Lord", "oneness",
     "السيد المطاع والإله المعبود، المربي لجميع خلقه، القائم على رعايتهم وإصلاحهم وتدبير شؤونهم، وهو المالك المنعم الجابر، رب كل شيء ومليكه."),
    (34, "الخلاق", "Al-Khallaaq", "The Ever-Creating", "creation",
     "الموجد لجميع الأشياء من العدم المبدع لها بتقديره على غير مثال سابق، يبدأ الخلق ثم يعيده، فيخلق ما يشاء متى شاء كيفما شاء."),
    (35, "القدير", "Al-Qadeer", "The All-Powerful", "power",
     "القادر على كل شيء قدرة تامة فلا يعجزه شيء، المقدر للأمور بعلمه وحكمته، ذو القدر العظيم والقدرة الكاملة المنزه عن أي عجز."),
    (36, "النصير", "An-Naseer", "The Helper", "protection",
     "الناصر المؤيد الذي لا يخذل أولياءه، والمانع المؤيد بالنصر لعباده المؤمنين كثير العون والإمداد بالقوة والتأييد لهم."),
    (37, "الغني", "Al-Ghaniyy", "The Self-Sufficient", "provision",
     "المستغني بذاته عن جميع خلقه، الذي لا يحتاج إلى أحد والخلائق كلهم مفتقرون إليه محتاجون لمنّه وفضله."),
    (38, "الحميد", "Al-Hameed", "The Praiseworthy", "majesty",
     "المستحق للحمد والثناء والتمجيد، المحمود بكل صفات الكمال والجمال، الممدوح بكل جميل وجليل."),
    (39, "المجيد", "Al-Majeed", "The Glorious", "majesty",
     "الموصوف بالمجد والجلال والرفعة والعظمة، المتعالي في قدره المُمَجَّد في سلطانه وملكه، المستحق للمجد والتمجيد."),
    (40, "الحق", "Al-Haqq", "The Truth", "oneness",
     "ثابت الوجود حقيقة بلا نكران وثقة بلا نقصان، فهو الحق والصدق الذي ليس فيه شك، وهو العدل الذي لا يظلم عنده أحد."),
    (41, "المبين", "Al-Mubeen", "The Clear", "knowledge",
     "الواضح الظاهر البين، فكل ما في الوجود دال عليه، وهو الذي يبين لعباده السبيل المستقيم ويوضح لهم الحق والصواب."),
    (42, "القوي", "Al-Qawiyy", "The Strong", "power",
     "ذو القوة المطلقة والقدرة التامة والعزم الشديد، والذي لا يعجزه شيء ولا يغالبه شيء، وكل الخلق ضعفاء عاجزون أمام قوته."),
    (43, "المتين", "Al-Mateen", "The Firm", "power",
     "القوي الشديد المقتدر، ذو القوة التامة الذي لا تتناقص قوته، ولا تضعف قدرته، ولا يمسه تعب ولا لغوب."),
    (44, "المنتقم", "Al-Muntaqim", "The Avenger", "power",
     "قاهر الجبابرة والعصاة، وقاصم ظهور المتكبرين والطغاة، ومعذب المجرمين العتاة، المتكفل بنصر عباده المؤمنين والقصاص من الظالمين."),
    (45, "العفو", "Al-'Afuww", "The Pardoner", "forgiveness",
     "كثير العفو والصفح عن خلقه، الذي يتجاوز عن عباده المذنبين ويعفو عن السيئات، ويضع عن عباده تبعات خطاياهم وآثامهم."),
    (46, "الغفور", "Al-Ghafoor", "The Forgiving", "forgiveness",
     "كثير المغفرة والستر لعباده، الذي يغفر ويعفو ويصفح عن الذنوب، ويتجاوز عن الخطايا ويستر الرزايا والعيوب."),
    (47, "الحليم", "Al-Haleem", "The Forbearing", "mercy",
     "ذو الصفح والأناة، الذي لا يعجِّل بالعقوبة والانتقام، والذي لا يحبس إنعامه عن عباده لأجل ذنوبهم فيرزق مطيعهم وعاصيهم."),
    (48, "القريب", "Al-Qareeb", "The Near", "mercy",
     "القريب بعلمه من عباده فيعلم سرهم ونجواهم، وهو القريب ممن دعاه يجيب دعوته ويقضي حاجته، سريع الإجابة."),
    (49, "المجيب", "Al-Mujeeb", "The Responsive", "mercy",
     "الذي يستجيب للداعين ويعطي السائلين ويكشف السوء عن المضطرين، يقابل الدعاء بالعطاء والسؤال بالقبول."),
    (50, "الحي", "Al-Hayy", "The Ever-Living", "oneness",
     "الباقي على الأبد الذي له كمال الحياة فلا يعتريه نقص، الموجود بذاته فلا يحتاج لأحد، ذو الحياة الخالدة الدائمة بلا ابتداء."),
    (51, "القيوم", "Al-Qayyoom", "The Self-Subsisting", "oneness",
     "القَيِّم على كل شيء بالرعاية والولاية، المستغني عن كل شيء، المتكفل بتدبير أمور الخلق وتصريف شؤونهم."),
    (52, "العلي", "Al-'Aliyy", "The Most High", "majesty",
     "ذو العلو، العالي على كل شيء، الرفيع فوق خلقه الذي يتجاوز كل شيء برفعته وعلوه، ذو القدر الأعلى في كماله وقدرته."),
    (53, "العظيم", "Al-'Azeem", "The Magnificent", "majesty",
     "جليل القدر ذو العظمة بذاته، المعظَّم الذي يهابه الخلق ويمجدونه ويسبحونه ويسجدون له، الذي له السلطان والكبرياء والقدرة على كل شيء."),
    (54, "الكبير", "Al-Kabeer", "The Most Great", "majesty",
     "العظيم الجليل كبير الشأن الكامل في ذاته، المنزه عن مشابهة مخلوقاته، ذو الكبرياء الذي لا مثيل له في العظمة والجلال."),
    (55, "المتعال", "Al-Muta'aal", "The Exalted", "majesty",
     "المستعلي على كل شيء بقدرته وقهره، الأعلى في كل شيء، فلا يضاهى في عظمته وسلطانه، المنزه عن صفات المخلوقين."),
    (56, "اللطيف", "Al-Lateef", "The Subtle Kind", "mercy",
     "الرفيق البرُّ بخلقه المحسن إليهم بألطافه الموصل رحمته إليهم بخفاء وستر من حيث لا يعلمون، العالم بدقائق الأمور."),
    (57, "الخبير", "Al-Khabeer", "The All-Aware", "knowledge",
     "الحكيم في تدبيره العليم بكل شيء، المدرك لحقيقة كل شيء، المحيط بأخبار كل شيء، المطلع على الظواهر والبواطن."),
    (58, "الوهاب", "Al-Wahhaab", "The Bestower", "provision",
     "المنعم الكريم المانح الذي يجود على خلقه بالعطايا والهبات وأنواع الخيرات، بحفاوة وسخاوة بلا مقابل أو حساب."),
    (59, "الرزاق", "Ar-Razzaaq", "The Provider", "provision",
     "المعيل لخلقه المتكفل برزقهم، الممدِّ لهم بأسباب معيشتهم، المنعم على خلقه بحوائجهم وإسباغ نعمه الظاهرة والباطنة عليهم."),
    (60, "الحسيب", "Al-Haseeb", "The Reckoner", "knowledge",
     "الشريف الجليل الذي له صفات الكمال والجلال، المحاسب والمجازي لخلقه على أعمالهم بعدله فلا يظلم عنده أحد."),
    (61, "الرقيب", "Ar-Raqeeb", "The Watchful", "knowledge",
     "المراقب الحافظ الذي يرى ويعلم كل شيء ولا يغيب عن علمه وسمعه وبصره شيء، المطلع على السر والعلانية."),
    (62, "الشهيد", "Ash-Shaheed", "The Witness", "knowledge",
     "الشاهد الحاضر الذي لا يغيب عن علمه شيء، والعالم المطلع على أعمال العباد وكل حدث يقع بين خلقه."),
    (63, "المقيت", "Al-Muqeet", "The Sustainer", "provision",
     "المقتدر الحفيظ، خالق الأقوات، المتكفِّل بإيصالها إلى الخلق، الرقيب المجازي المعيل بالإعاشة لكل مخلوق."),
    (64, "الفتاح", "Al-Fattaah", "The Opener", "provision",
     "الحاكم الذي يفتح أبواب الخير والرزق والنصر لعباده، وهو الذي يفتح ما انغلق من أمور الخلق فييسرها لهم بفضله وكرمه."),
    (65, "العليم", "Al-'Aleem", "The All-Knowing", "knowledge",
     "فائق العلم كامله، الذي يعلم ما كان وما يكون والمطلع على كل مكنون، العالم الذي أحاط علمه بجميع الأشياء ظاهرها وباطنها."),
    (66, "الحكيم", "Al-Hakeem", "The Wise", "knowledge",
     "ذو الفعل السديد والصنع المتقن والقول الحميد والتدبير الرشيد، الموصوف بكمال الحكمة العالم بعواقب الأمور."),
    (67, "الجامع", "Al-Jaami'", "The Gatherer", "majesty",
     "القادر على جمع خلقه كيف شاء ومتى أراد، فهو جامع الخلق في موقف القيامة، وجامع أجزاء المخلوقات عند البعث والنشور."),
    (68, "القادر", "Al-Qaadir", "The Able", "power",
     "المستطيع ذو القدرة الذي يمكنه فعل كل شيء، والذي يقدر بمشيئته على فعل ما يريد بلا عجز أو فتور."),
    (69, "المقتدر", "Al-Muqtadir", "The Omnipotent", "power",
     "عظيم القدرة كامل القوة لا يقدر عليه أحد، فهو القادر على كل شيء لا يمتنع عليه شيء ولا يعجزه شيء."),
    (70, "فاطر السموات والأرض", "Faatir as-Samawati wal-Ard", "Originator of the heavens and the earth", "creation",
     "مبدعهما الذي أوجدهما وفتق رتقهما وابتدأ خلقهما، وورد هذا الاسم في القرآن الكريم مرات منها قوله تعالى: ﴿الْحَمْدُ لِلَّهِ فَاطِرِ السَّمَاوَاتِ وَالْأَرْضِ﴾."),
    (71, "عالم الغيب والشهادة", "Aalim al-Ghaybi wash-Shahaadah", "Knower of the unseen and the seen", "knowledge",
     "الذي يعلم كل ما غاب عن الخلق وكل ما حضر، المحيط بكل ما خفي واستتر أو بان وظهر."),
    (72, "بديع السموات والأرض", "Badee' as-Samawati wal-Ard", "Originator of the heavens and the earth", "creation",
     "الخالق الفذ المبدع المتفرد بالخلق على غير مثال سابق، الذي تجلى إبداعه وجمال صنعه وتفرده في تنوع مخلوقاته."),
    (73, "نور السماوات والأرض", "Noor as-Samawati wal-Ard", "Light of the heavens and the earth", "majesty",
     "منوّر السماوات والأرض، وهادي أهل السماوات والأرض؛ فهم بنوره إلى الحق يهتدون وبهداه من الضلالة ينجون."),
    (74, "الواحد", "Al-Waahid", "The One", "oneness",
     "الفرد الذي لا ثاني له، ولا قسيم لذاته ولا شبيه له ولا شريك له ولا نظير له، وهو وحده المتفرد بالملك والحكم والتدبير."),
    (75, "الأحد", "Al-Ahad", "The Unique", "oneness",
     "المتفرِّد في عليائه ووحدانيته وصفات كماله وجلاله، المنزه عن الشريك والمثيل ﴿قُلْ هُوَ اللَّهُ أَحَدٌ﴾."),
    (76, "الصمد", "As-Samad", "The Eternal Refuge", "oneness",
     "الدائم الباقي الذي لا يزول، والسيد المقصود إليه في الرغائب المستغاث به عند المصائب، الذي يقصده الخلق كلهم في قضاء حوائجهم."),
    (77, "القاهر", "Al-Qaahir", "The Irresistible", "power",
     "الغالب لخلقه بقدرته وسلطانه، المنفرد بالتدبير والخلق مجبورون تحت إرادته ومشيئته، المستعلي على خلقه بكمال قدرته وقهره."),
    (78, "القهار", "Al-Qahhaar", "The Subduer", "power",
     "الغالب على كل خلقه، الذي قهرهم بالموت والفناء، وهو القوي الذي لا يقاوم، وذو السلطان والسيطرة الكاملة على جميع الأمور."),
    (79, "العالم", "Al-'Aalim", "The Knower", "knowledge",
     "ذو العلم المطلق الشامل، الذي لا يعزب عنه مثقال ذرة في السماوات ولا في الأرض، وهو الذي أحاط علمه بكل شيء."),
    (80, "الحكم", "Al-Hakam", "The Judge", "majesty",
     "القاضي بالحق والعدل، فله الحكم وحده، يحكم بين خلقه بعدله وحكمته ويفصل بين الحق والباطل."),
    (81, "الإله", "Al-Ilaah", "The Deity", "oneness",
     "المعبود بحق فلا إله غيره وكل ما سواه باطل، قال تعالى: ﴿وَإِلَٰهُكُمْ إِلَٰهٌ وَاحِدٌ﴾."),
    (82, "الحفي", "Al-Hafiyy", "The Gracious Host", "mercy",
     "البرّ اللطيف الذي يحتفي بعباده، ويقوم في حاجتهم ويبرُّهم ويبالغ في كرامتهم والعناية والاهتمام بأمرهم."),
    (83, "الودود", "Al-Wadood", "The Loving", "mercy",
     "المتودد إلى أوليائه وأهل طاعته بالمحبة والمغفرة، المُحِبُّ الوادُّ لأوليائه وعباده الصالحين، وهو المحبوب في قلوب المؤمنين."),
    (84, "الحافظ", "Al-Haafiz", "The Preserver", "protection",
     "الذي يحرس عباده ويرعاهم ويحفظ أولياءه ويتولاهم ويصرف عنهم السوء بفضله، ويحفظ على الخلق أعمالهم."),
    (85, "الحفيظ", "Al-Hafeez", "The Guardian", "protection",
     "الحافظ لأعمال الخلق العالم بكل شيء الذي لا يعزب عنه مثقال ذرة، والحافظ لعباده من الشر والأذى."),
    (86, "الغالب", "Al-Ghaalib", "The Prevailing", "power",
     "القاهر المسيطر ذو السيادة والقوة والغلبة، الذي يبلغ مراده من خلقه أحبوا ذلك أم كرهوا، ولا غالب إلا الله."),
    (87, "الكافي", "Al-Kaafi", "The Sufficient", "protection",
     "الحافظ الحامي لعباده المؤمنين فيرد عنهم الكيد والأذى ويحفظهم من كل سوء، وهو المعطي الموفي لخلقه كفايتهم."),
    (88, "المنّان", "Al-Mannaan", "The Benefactor", "provision",
     "الجواد الكريم وافر العطايا وعظيم الهبات كثير الإحسان لخلقه، المنعم ابتداءً فله المنة على خلقه وليس لأحد منة عليه."),
    (89, "المستعان", "Al-Musta'aan", "The One Sought for Help", "protection",
     "الذي يُطلب منه العون والمدد وحده سبحانه، الذي يستعين به العباد فيعينهم منّاً منه وفضلا."),
    (90, "الوارث", "Al-Waarith", "The Inheritor", "majesty",
     "الباقي بعد موت العباد وفناء الخلق، الذي ترجع إليه الأملاك وقد هلك المُلاَّك، الحي الدائم الباقي الذي يرث الأرض ومن عليها."),
    (91, "الكفيل", "Al-Kafeel", "The Surety", "protection",
     "الحافظ الكافل الضامن لخلقه، المتكفل بتوفير حاجات وأرزاق خلقه وآجالهم، وهو الرقيب الشاهد عليهم."),
    (92, "الوكيل", "Al-Wakeel", "The Trustee", "protection",
     "القيِّم الكفيل بأرزاق العباد، الموكول إليه مصالحهم العالم بأحوالهم، والمفوض بتدبير أمورهم."),
    (93, "الغفار", "Al-Ghaffaar", "The Oft-Forgiving", "forgiveness",
     "كثير المغفرة والستر على عباده، الذي يظهر الجميل ويستر القبيح ويغفر الذنوب والأوزار صغيرها وكبيرها."),
    (94, "الكريم", "Al-Kareem", "The Generous", "provision",
     "المنعم الجواد كثير الخير والكرم الذي يعطي بغير عوض ولا سبب، الذي إذا قدر عفا وإذا وعد وفى وإذا أعطى زاد من فضله."),
    (95, "الشكور", "Ash-Shakoor", "The Most Appreciative", "forgiveness",
     "الكريم الذي يكافئ بالكثير على اليسير، فيشكر اليسير من الطاعة ويعطي عليه الكثير من الثواب، ويثني على عباده المؤمنين."),
    (96, "الأعلى", "Al-A'laa", "The Most High", "majesty",
     "الأعلى من كل شيء، العلي الأشرف الذي له العلو وحده ولا شيء يعلو عليه، وهو الأعلى المنزه عن الشريك والشبيه."),
    (97, "الأكرم", "Al-Akram", "The Most Generous", "provision",
     "أكرم الأكرمين الجواد الذي لا يوازيه كريم، فهو الأكثر في إحسانه والأجود في عطاءه، وهو الحليم عن جهل العباد."),
    (98, "مالك الملك", "Maalik al-Mulk", "Owner of Dominion", "majesty",
     "السيد المالك الحقيقي لكل ما يملك، المتصرف في ملكه كيف يشاء فهو الملك الحقيقي المتصرف بما شاء كيف شاء."),
    (99, "ذو الجلال والإكرام", "Dhul-Jalaali wal-Ikraam", "Lord of Majesty and Honour", "majesty",
     "الموصوف بالجلال والعظمة والكبرياء الذي له الإكرام من جميع خلقه، فهو المستحق لأن يجل فلا يجحد ولا يكفر به."),
]

COMPOUND: list[tuple[int, str, str, str]] = [
    (100, "غافر الذنب", "Ghaafir adh-Dhanb", "Forgiver of sin"),
    (101, "قابل التوب", "Qaabil at-Tawb", "Accepter of repentance"),
    (102, "رفيع الدرجات", "Rafee' ad-Darajaat", "Exalter of ranks"),
    (103, "أحسن الخالقين", "Ahsan al-Khaaliqeen", "Best of creators"),
    (104, "خالق كل شيء", "Khaaliq kulli shay'", "Creator of all things"),
    (105, "أسرع الحاسبين", "Asra' al-Haasibeen", "Swiftest of reckoners"),
    (106, "سريع الحساب", "Saree' al-Hisaab", "Swift in reckoning"),
    (107, "سريع العقاب", "Saree' al-'Iqaab", "Swift in punishment"),
    (108, "شديد العقاب", "Shadeed al-'Iqaab", "Severe in punishment"),
    (109, "شديد المحال", "Shadeed al-Mihaal", "Severe in power"),
    (110, "فالق الحب والنوى", "Faaliq al-Habbi wan-Nawa", "Splitter of grain and date-stone"),
    (111, "فالق الإصباح", "Faaliq al-Isbaah", "Cleaver of daybreak"),
    (112, "القائم بالقسط", "Al-Qaa'im bil-Qist", "Upholder of justice"),
    (113, "أهل التقوى", "Ahl at-Taqwa", "Worthy of piety"),
    (114, "أهل المغفرة", "Ahl al-Maghfirah", "Worthy of forgiveness"),
    (115, "أرحم الراحمين", "Arham ar-Raahimeen", "Most Merciful of the merciful"),
    (116, "أحكم الحاكمين", "Ahkam al-Haakimeen", "Most Just of judges"),
    (117, "فعال لما يريد", "Fa''aal lima yureed", "Doer of what He wills"),
    (118, "ذو الفضل", "Dhul-Fadl", "Possessor of bounty"),
    (119, "ذو الرحمة", "Dhul-Rahmah", "Possessor of mercy"),
    (120, "ذو المغفرة", "Dhul-Maghfirah", "Possessor of forgiveness"),
    (121, "ذو القوة", "Dhul-Quwwah", "Possessor of strength"),
    (122, "ذو العرش", "Dhul-'Arsh", "Lord of the Throne"),
    (123, "ذو انتقام", "Dhul-Intiqam", "Possessor of vengeance"),
    (124, "ذو الطول", "Dhut-Tawl", "Possessor of abundance"),
    (125, "ذو المعارج", "Dhul-Ma'aarij", "Lord of the ascending ways"),
    (126, "خير الناصرين", "Khayr an-Naasireen", "Best of helpers"),
    (127, "خير الرازقين", "Khayr ar-Raaziqeen", "Best of providers"),
    (128, "خير الفاصلين", "Khayr al-Faasileen", "Best of judges/separators"),
    (129, "خير الحاكمين", "Khayr al-Haakimeen", "Best of rulers"),
    (130, "خير الفاتحين", "Khayr al-Faatiheen", "Best of openers"),
    (131, "خير الغافرين", "Khayr al-Ghaafireen", "Best of forgivers"),
    (132, "خير الوارثين", "Khayr al-Waaritheen", "Best of inheritors"),
    (133, "خير الراحمين", "Khayr ar-Raahimeen", "Best of those who show mercy"),
    (134, "خير المنزلين", "Khayr al-Munzileen", "Best of those who send down"),
]

SUNNAH: list[tuple[int, str, str, str]] = [
    (1, "القابض", "Al-Qaabid", "The Withholder"),
    (2, "الباسط", "Al-Baasit", "The Extender"),
    (3, "الجميل", "Al-Jameel", "The Beautiful"),
    (4, "السُّبُّوحُ", "As-Subbooh", "The Glorified"),
    (5, "المُقَدِّمُ", "Al-Muqaddim", "The Advancer"),
    (6, "المؤَخِّرُ", "Al-Mu'akhkhir", "The Delayer"),
    (7, "السَّيِّدُ", "As-Sayyid", "The Master"),
    (8, "الدَّيَّانُ", "Ad-Dayyaan", "The Judge / Recompenser"),
    (9, "الرفيق", "Ar-Rafeeq", "The Gentle"),
    (10, "الشافي", "Ash-Shaafi", "The Healer"),
    (11, "السَّتِيرُ", "As-Sitteer", "The Concealer"),
    (12, "الحَيِيُّ", "Al-Hayiyy", "The Modest"),
]


def slug(translit: str, arabic: str) -> str:
    s = translit.lower()
    for a, b in [
        ("'", ""), ("'", ""), ("`", ""), (" ", "-"), ("/", "-"),
        (".", ""), (",", ""), ("(", ""), (")", ""),
    ]:
        s = s.replace(a, b)
    while "--" in s:
        s = s.replace("--", "-")
    return s.strip("-") or f"name-{hash(arabic) % 10000}"


def dart_str(s: str) -> str:
    return "'" + s.replace("\\", "\\\\").replace("'", "\\'") + "'"


def theme_for_compound(ar: str) -> str:
    if any(x in ar for x in ("رحم", "رأف", "رأف")):
        return "mercy"
    if any(x in ar for x in ("غافر", "مغفر", "توب", "عفو")):
        return "forgiveness"
    if any(x in ar for x in ("خالق", "فاطر", "فالق", "بديع")):
        return "creation"
    if any(x in ar for x in ("قو", "عقاب", "انتقام", "شديد")):
        return "power"
    if any(x in ar for x in ("رازق", "فضل", "طول")):
        return "provision"
    if any(x in ar for x in ("علم", "حساب", "حاكم", "فصل", "قسط")):
        return "knowledge"
    return "majesty"


def emit_name(
    *,
    nid: str,
    index: int,
    arabic: str,
    translit: str,
    meaning_en: str,
    meaning_ar: str,
    explanation_en: str,
    explanation_ar: str,
    source: str,
    collection: str,
    evidence_en: str,
    evidence_ar: str,
    theme: str,
) -> str:
    return f"""    DivineName(
      id: {dart_str(nid)},
      index: {index},
      arabic: {dart_str(arabic)},
      transliteration: {dart_str(translit)},
      meaningEn: {dart_str(meaning_en)},
      meaningAr: {dart_str(meaning_ar)},
      explanationEn: {dart_str(explanation_en)},
      explanationAr: {dart_str(explanation_ar)},
      sourceKind: AsmaSourceKind.{source},
      collection: AsmaCollectionKind.{collection},
      evidenceNoteEn: {dart_str(evidence_en)},
      evidenceNoteAr: {dart_str(evidence_ar)},
      themeIds: [{dart_str(theme)}],
    ),"""


def main() -> None:
    lines: list[str] = []
    lines.append("import '../models/asma.dart';")
    lines.append("")
    lines.append("/// Names of Allah for Al Noor.")
    lines.append("///")
    lines.append("/// Primary ranking (1–99) and compound Quranic titles follow the")
    lines.append("/// Quranic listing presented on SurahQuran.com")
    lines.append("/// (https://surahquran.com/99-Names-of-Allah-with-Meaning.html).")
    lines.append("/// Arabic explanations are taken from that educational compilation.")
    lines.append("/// Extra Sunnah names are listed separately and are not mixed into")
    lines.append("/// the primary 1–99 ranking. This is not a claim that the prophetic")
    lines.append("/// promise is limited to one fixed list.")
    lines.append("class AsmaUlHusna {")
    lines.append("  AsmaUlHusna._();")
    lines.append("")
    lines.append("  static const attributionEn =")
    lines.append("      'Primary order and Arabic explanations follow the SurahQuran.com '")
    lines.append("      'educational compilation of Beautiful Names occurring in the Quran '")
    lines.append("      '(with compound Quranic titles and selected Sunnah names shown in '")
    lines.append("      'separate sections). The Bukhari/Muslim hadith affirms ninety-nine '")
    lines.append("      'Names without listing them. Meanings are for learning—not exhaustive creed.';")
    lines.append("")
    lines.append("  static const attributionAr =")
    lines.append("      'الترتيب الأساسي والشروح العربية وفق تجميع تعليمي لموقع سورة قرآن لأسماء الله '")
    lines.append("      'الحسنى الواردة في القرآن (مع الأسماء المركبة وأسماً من السنة في أقسام منفصلة). '")
    lines.append("      'حديث البخاري ومسلم يثبت تسعة وتسعين اسماً دون سردها. المعاني للتعليم.';")
    lines.append("")
    lines.append("  static const artworkAsset = 'assets/images/asma_ul_husna_grid.png';")
    lines.append("")
    lines.append("  static const sourceUrl =")
    lines.append("      'https://surahquran.com/99-Names-of-Allah-with-Meaning.html';")
    lines.append("")
    lines.append("  static const themes = <AsmaTheme>[")
    for tid, en, ar in [
        ("mercy", "Mercy and kindness", "الرحمة واللطف"),
        ("oneness", "Oneness and divinity", "التوحيد والألوهية"),
        ("majesty", "Majesty and perfection", "العظمة والكمال"),
        ("knowledge", "Knowledge and awareness", "العلم والإحاطة"),
        ("creation", "Creation", "الخلق"),
        ("forgiveness", "Forgiveness and repentance", "المغفرة والتوبة"),
        ("power", "Power and might", "القدرة والعزة"),
        ("protection", "Protection and guardianship", "الحفظ والولاية"),
        ("provision", "Provision and giving", "الرزق والعطاء"),
    ]:
        lines.append(
            f"    AsmaTheme(id: '{tid}', nameEn: '{en}', nameAr: '{ar}'),"
        )
    lines.append("  ];")
    lines.append("")

    primary_blocks = []
    for idx, ar, tr, men, theme, expl_ar in PRIMARY:
        nid = "allah" if idx == 1 else slug(tr, ar)
        expl_en = (
            f"Educational Arabic explanation for {tr} ({ar}), following the "
            f"SurahQuran.com compilation. See the Arabic text for the full wording."
        )
        primary_blocks.append(
            emit_name(
                nid=nid,
                index=idx,
                arabic=ar,
                translit=tr,
                meaning_en=men,
                meaning_ar=ar,
                explanation_en=expl_en,
                explanation_ar=expl_ar,
                source="quran",
                collection="primary",
                evidence_en="Listed in the SurahQuran.com Quranic Names compilation.",
                evidence_ar="مدرج في تجميع أسماء الله الحسنى القرآنية على موقع سورة قرآن.",
                theme=theme,
            )
        )

    compound_blocks = []
    for idx, ar, tr, men in COMPOUND:
        compound_blocks.append(
            emit_name(
                nid=slug(tr, ar),
                index=idx,
                arabic=ar,
                translit=tr,
                meaning_en=men,
                meaning_ar=ar,
                explanation_en=(
                    f"Compound Quranic title ({ar}). Catalogued separately from the "
                    f"primary 1–99 ranking; open the source page for fuller notes."
                ),
                explanation_ar=(
                    f"اسم مركّب وارد في القرآن الكريم: {ar}. معروض في قسم منفصل عن "
                    f"الترتيب الأساسي ١–٩٩."
                ),
                source="quran",
                collection="quranCompound",
                evidence_en="Compound Beautiful Name occurring in the Quran (SurahQuran.com section).",
                evidence_ar="من الأسماء الحسنى المركبة الواردة في القرآن (قسم موقع سورة قرآن).",
                theme=theme_for_compound(ar),
            )
        )

    sunnah_blocks = []
    for idx, ar, tr, men in SUNNAH:
        sunnah_blocks.append(
            emit_name(
                nid=slug(tr, ar),
                index=idx,
                arabic=ar,
                translit=tr,
                meaning_en=men,
                meaning_ar=ar,
                explanation_en=(
                    f"Name reported in authentic Sunnah compilations: {tr}. "
                    f"Shown in a separate section, not mixed into the primary Quranic ranking."
                ),
                explanation_ar=(
                    f"اسم ورد في السنة الصحيحة: {ar}. يُعرض في قسم منفصل عن الترتيب القرآني الأساسي."
                ),
                source="sunnah",
                collection="sunnahExtra",
                evidence_en="Included among Names reported from the authentic Sunnah.",
                evidence_ar="من الأسماء الواردة في السنة الصحيحة.",
                theme="majesty",
            )
        )

    lines.append("  static const primary = <DivineName>[")
    lines.extend(primary_blocks)
    lines.append("  ];")
    lines.append("")
    lines.append("  static const compoundQuran = <DivineName>[")
    lines.extend(compound_blocks)
    lines.append("  ];")
    lines.append("")
    lines.append("  static const sunnahExtra = <DivineName>[")
    lines.extend(sunnah_blocks)
    lines.append("  ];")
    lines.append("")
    lines.append("  /// All browsable Names (primary + compound + Sunnah extras).")
    lines.append("  static List<DivineName> get all =>")
    lines.append("      [...primary, ...compoundQuran, ...sunnahExtra];")
    lines.append("")
    lines.append("  static AsmaTheme? themeById(String id) {")
    lines.append("    for (final theme in themes) {")
    lines.append("      if (theme.id == id) return theme;")
    lines.append("    }")
    lines.append("    return null;")
    lines.append("  }")
    lines.append("")
    lines.append("  static DivineName? byId(String id) {")
    lines.append("    for (final name in all) {")
    lines.append("      if (name.id == id) return name;")
    lines.append("    }")
    lines.append("    return null;")
    lines.append("  }")
    lines.append("")
    lines.append("  static DivineName? byIndex(int index) {")
    lines.append("    for (final name in primary) {")
    lines.append("      if (name.index == index) return name;")
    lines.append("    }")
    lines.append("    return null;")
    lines.append("  }")
    lines.append("")
    lines.append("  static List<DivineName> forCollection(AsmaCollectionKind kind) {")
    lines.append("    switch (kind) {")
    lines.append("      case AsmaCollectionKind.primary:")
    lines.append("        return primary;")
    lines.append("      case AsmaCollectionKind.quranCompound:")
    lines.append("        return compoundQuran;")
    lines.append("      case AsmaCollectionKind.sunnahExtra:")
    lines.append("        return sunnahExtra;")
    lines.append("    }")
    lines.append("  }")
    lines.append("")
    lines.append("  static List<DivineName> related(DivineName name, {int limit = 8}) {")
    lines.append("    final sameTheme = <DivineName>[];")
    lines.append("    final sameCollection = <DivineName>[];")
    lines.append("    for (final other in all) {")
    lines.append("      if (other.id == name.id) continue;")
    lines.append("      final shared = other.themeIds.any(name.themeIds.contains);")
    lines.append("      if (shared) {")
    lines.append("        sameTheme.add(other);")
    lines.append("      } else if (other.collection == name.collection) {")
    lines.append("        sameCollection.add(other);")
    lines.append("      }")
    lines.append("    }")
    lines.append("    return [...sameTheme, ...sameCollection].take(limit).toList();")
    lines.append("  }")
    lines.append("")
    lines.append("  static List<String> quizOptions(DivineName current) {")
    lines.append("    final pool = primary.where((n) => n.id != current.id).toList();")
    lines.append("    pool.shuffle();")
    lines.append("    final options = <String>{current.meaningEn};")
    lines.append("    for (final name in pool) {")
    lines.append("      if (options.length >= 4) break;")
    lines.append("      options.add(name.meaningEn);")
    lines.append("    }")
    lines.append("    final list = options.toList()..shuffle();")
    lines.append("    return list;")
    lines.append("  }")
    lines.append("")
    lines.append("  static List<DivineName> search({")
    lines.append("    String query = '',")
    lines.append("    String? themeId,")
    lines.append("    AsmaSourceKind? sourceKind,")
    lines.append("    AsmaCollectionKind? collection,")
    lines.append("    bool favoritesOnly = false,")
    lines.append("    Set<String> favoriteIds = const {},")
    lines.append("  }) {")
    lines.append("    final q = query.trim().toLowerCase();")
    lines.append("    final list = all.where((name) {")
    lines.append("      if (collection != null && name.collection != collection) return false;")
    lines.append("      if (sourceKind != null && name.sourceKind != sourceKind) return false;")
    lines.append("      if (themeId != null && !name.themeIds.contains(themeId)) return false;")
    lines.append("      if (favoritesOnly && !favoriteIds.contains(name.id)) return false;")
    lines.append("      if (q.isEmpty) return true;")
    lines.append("      final hay = [")
    lines.append("        name.arabic,")
    lines.append("        name.transliteration,")
    lines.append("        name.meaningEn,")
    lines.append("        name.meaningAr,")
    lines.append("        name.explanationEn,")
    lines.append("        name.explanationAr,")
    lines.append("        '${name.index}',")
    lines.append("        ...name.themeIds,")
    lines.append("      ].join(' ').toLowerCase();")
    lines.append("      return hay.contains(q);")
    lines.append("    }).toList();")
    lines.append("    list.sort((a, b) {")
    lines.append("      final c = a.collection.index.compareTo(b.collection.index);")
    lines.append("      if (c != 0) return c;")
    lines.append("      return a.index.compareTo(b.index);")
    lines.append("    });")
    lines.append("    return list;")
    lines.append("  }")
    lines.append("}")
    lines.append("")

    OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote {OUT} ({len(PRIMARY)} primary, {len(COMPOUND)} compound, {len(SUNNAH)} sunnah)")


if __name__ == "__main__":
    main()
