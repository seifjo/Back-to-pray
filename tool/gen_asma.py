# -*- coding: utf-8 -*-
from pathlib import Path

names = [
("allah",1,"الله","Allah","Allah","الله","The One Who is truly worshipped; this Name comprises divinity and perfection.","الذي يُعبد بحق؛ يدل على الألوهية والكمال.","quran","mercy"),
("al-ahad",2,"الأحد","Al-Ahad","The Unique","الأحد","The One Who is unique in His Self, attributes, and divinity.","المتفرّد في ذاته وصفاته وألوهيته.","quran","oneness"),
("al-alaa",3,"الأعلى","Al-A'laa","The Most High","الأعلى","The One above everything in power and exalted above every deficiency.","العليّ فوق كل شيء، المنزّه عن كل نقص.","quran","majesty"),
("al-akram",4,"الأكرم","Al-Akram","The Most Generous","الأكرم","The One unequalled in perfect generosity.","الذي لا يُدانى في كرمه التام.","quran","mercy"),
("al-ilaah",5,"الإله","Al-Ilaah","The One worthy of worship","الإله","The One Who alone deserves to be worshipped.","الذي يستحق العبادة وحده.","quran","oneness"),
("al-awwal",6,"الأول","Al-Awwal","The First","الأول","The One before Whom there was nothing.","الذي ليس قبله شيء.","quran","majesty"),
("al-aakhir",7,"الآخر","Al-Aakhir","The Last","الآخر","The One Who remains after everything else has ended.","الذي يبقى بعد فناء كل شيء.","quran","majesty"),
("adh-dhaahir",8,"الظاهر","Adh-Dhaahir","The Most Apparent","الظاهر","The Uppermost One, apparent by His signs and above His creation.","العالي الظاهر بآياته فوق خلقه.","quran","majesty"),
("al-baatin",9,"الباطن","Al-Baatin","The Most Hidden","الباطن","The One Who knows the innermost secrets of everything.","العليم بأسرار كل شيء وبواطنه.","quran","knowledge"),
("al-baari",10,"البارئ","Al-Baari'","The Originator","البارئ","The One Who originated creation and fashioned beings by His power.","الذي برأ الخلق وصوّرهم بقدرته.","quran","creation"),
("al-barr",11,"البر","Al-Barr","The Most Kind","البر","The One Who treats the creation with kindness and rectifies their affairs.","الذي يُحسن إلى خلقه ويُصلح شؤونهم.","quran","mercy"),
("al-baseer",12,"البصير","Al-Baseer","The All-Seeing","البصير","The One from Whom nothing is hidden.","الذي لا يخفى عليه شيء.","quran","knowledge"),
("at-tawwaab",13,"التواب","At-Tawwaab","The Acceptor of repentance","التواب","The One Who guides to repentance and accepts it.","الذي يوفّق للتوبة ويقبلها.","quran","forgiveness"),
("al-jabbaar",14,"الجبار","Al-Jabbaar","The Compeller","الجبار","The One to Whose might creation submits, Who mends the broken.","الذي يخضع له الخلق، ويجبر الكسير.","quran","power"),
("al-haafidh",15,"الحافظ","Al-Haafidh","The Protector","الحافظ","The One Who guards the heavens, the earth, and His servants.","الذي يحفظ السماوات والأرض وعباده.","quran","protection"),
("al-haseeb",16,"الحسيب","Al-Haseeb","The Reckoner","الحسيب","The One Who preserves deeds, brings to account, and suffices His servants.","الذي يحصي الأعمال ويكفي عباده.","quran","knowledge"),
("al-hafeedh",17,"الحفيظ","Al-Hafeedh","The Guardian","الحفيظ","The One Who protects from harm and perfectly preserves deeds.","الذي يحفظ من السوء ويحفظ الأعمال.","quran","protection"),
("al-hafiyy",18,"الحفي","Al-Hafiyy","The Benevolent","الحفي","The One ever kind to His servants and responsive to supplication.","اللطيف بعباده المجيب لدعائهم.","quran","mercy"),
("al-haqq",19,"الحق","Al-Haqq","The Truth","الحق","The One true in His existence, attributes, words, and actions.","الحق في ذاته وصفاته وأقواله وأفعاله.","quran","majesty"),
("al-mubeen",20,"المبين","Al-Mubeen","The Clear and Manifest","المبين","The One Whose Lordship and right to worship are clear.","الذي تبيّنت ربوبيته واستحقاقه للعبادة.","quran","majesty"),
("al-hakeem",21,"الحكيم","Al-Hakeem","The All-Wise","الحكيم","The One fully wise in what He decrees, says, and does.","الحكيم في قضائه وقوله وفعله.","quran","knowledge"),
("al-haleem",22,"الحليم","Al-Haleem","The Forbearing","الحليم","The One Who does not hasten to punish, giving time to repent.","الذي لا يعاجل بالعقوبة ويمهل للتوبة.","quran","mercy"),
("al-hameed",23,"الحميد","Al-Hameed","The Praiseworthy","الحميد","The One Who fully deserves praise for His Self, Names, and actions.","المستحق للحمد لذاته وأسمائه وأفعاله.","quran","majesty"),
("al-hayy",24,"الحي","Al-Hayy","The Ever-Living","الحي","The Ever-Living without beginning or end, Who never dies.","الحيّ بلا بداية ولا نهاية، الذي لا يموت.","quran","majesty"),
("al-qayyoom",25,"القيوم","Al-Qayyoom","The Self-Subsisting","القيوم","The One upon Whom everything depends, needing none.","الذي يقوم بنفسه ويقوم به كل شيء.","quran","majesty"),
("al-khabeer",26,"الخبير","Al-Khabeer","The Fully Aware","الخبير","The One Who fully knows the condition and outcome of everything.","العليم بحقيقة كل شيء وعواقبه.","quran","knowledge"),
("al-khaaliq",27,"الخالق","Al-Khaaliq","The Creator","الخالق","The Creator and Maker of everything.","خالق كل شيء وموجده.","quran","creation"),
("al-khallaq",28,"الخلاق","Al-Khallaaq","The Ever-Creating","الخلاق","The Creator Who creates again and again.","الذي يخلق خلقاً بعد خلق.","quran","creation"),
("ar-raoof",29,"الرؤوف","Ar-Ra'oof","The Compassionate","الرؤوف","The Compassionate and Kind to His servants.","الرؤوف بعباده الرحيم بهم.","quran","mercy"),
("ar-rahmaan",30,"الرحمن","Ar-Rahmaan","The Most Merciful","الرحمن","The One Whose mercy encompasses all creation.","الذي وسعت رحمته كل شيء.","quran","mercy"),
("ar-raheem",31,"الرحيم","Ar-Raheem","The Especially Merciful","الرحيم","The Bestower of mercy, especially upon the believers.","الذي يرحم عباده، وخصّ المؤمنين برحمته.","quran","mercy"),
("ar-razzaaq",32,"الرزاق","Ar-Razzaaq","The Great Provider","الرزاق","The One Who provides abundantly for all creation.","الذي يرزق الخلق رزقاً واسعاً.","quran","provision"),
("ar-raqeeb",33,"الرقيب","Ar-Raqeeb","The Ever-Watchful","الرقيب","The Ever-Watchful Guardian over His servants.","الرقيب على عباده المطلع عليهم.","quran","knowledge"),
("as-salaam",34,"السلام","As-Salaam","The Flawless","السلام","The One free of every deficiency and defect.","السالم من كل عيب ونقص.","quran","majesty"),
("as-samee",35,"السميع","As-Samee'","The All-Hearing","السميع","The One Who hears all sounds and speech.","الذي يسمع كل الأصوات والأقوال.","quran","knowledge"),
("ash-shaakir",36,"الشاكر","Ash-Shaakir","The Appreciative","الشاكر","The One Who appreciates and rewards the deeds of His servants.","الذي يشكر لعباده عملهم ويجزيهم.","quran","mercy"),
("ash-shakoor",37,"الشكور","Ash-Shakoor","The Most Appreciative","الشكور","The One most ready to appreciate and reward abundantly.","الذي يضاعف الثواب ويشكر العمل القليل.","quran","mercy"),
("ash-shaheed",38,"الشهيد","Ash-Shaheed","The Witness","الشهيد","The Witness over all that His servants do.","الشهيد على أعمال عباده.","quran","knowledge"),
("as-samad",39,"الصمد","As-Samad","The Eternal Refuge","الصمد","The Perfect Lord upon Whom all creation depends.","السيد الكامل الذي يصمد إليه الخلق.","quran","oneness"),
("al-aalim",40,"العالم","Al-'Aalim","The All-Knower","العالم","The Knower of the seen and the unseen.","العالم بالغيب والشهادة.","quran","knowledge"),
("al-azeez",41,"العزيز","Al-'Azeez","The Almighty","العزيز","The Almighty, Invincible One.","العزيز الغالب الذي لا يُغلب.","quran","power"),
("al-adheem",42,"العظيم","Al-'Adheem","The Magnificent","العظيم","The Tremendous and Magnificent One.","العظيم في ذاته وصفاته.","quran","majesty"),
("al-afuww",43,"العفو","Al-'Afuww","The Pardoner","العفو","The One Who pardons again and again.","الذي يعفو ويعيد العفو.","quran","forgiveness"),
("al-aleem",44,"العليم","Al-'Aleem","The All-Knowing","العليم","The One Whose knowledge encompasses everything.","الذي أحاط علمه بكل شيء.","quran","knowledge"),
("al-aliyy",45,"العلي","Al-'Aliyy","The Exalted","العلي","The Exalted above His creation.","العليّ فوق خلقه.","quran","majesty"),
("al-ghaffaar",46,"الغفار","Al-Ghaffaar","The Oft-Forgiving","الغفار","The One Who forgives repeatedly.","الذي يغفر الذنوب مرة بعد مرة.","quran","forgiveness"),
("al-ghafoor",47,"الغفور","Al-Ghafoor","The All-Forgiving","الغفور","The One Who forgives extensively.","الذي يغفر الذنوب مغفرة واسعة.","quran","forgiveness"),
("al-ghaniyy",48,"الغني","Al-Ghaniyy","The Self-Sufficient","الغني","The Independent One free of all needs.","الغنيّ عن جميع خلقه.","quran","majesty"),
("al-fattaah",49,"الفتاح","Al-Fattaah","The Opener","الفتاح","The Judge and Opener Who distinguishes truth from falsehood.","الذي يفتح بالحق ويفصل بين الخلق.","quran","provision"),
("al-qaadir",50,"القادر","Al-Qaadir","The Fully Able","القادر","The One fully able to do whatever He wills.","القادر على ما يشاء.","quran","power"),
("al-qaahir",51,"القاهر","Al-Qaahir","The Subduer","القاهر","The Invincible Subduer over His creation.","القاهر فوق عباده.","quran","power"),
("al-quddoos",52,"القدوس","Al-Quddoos","The Pure","القدوس","The Pure and Perfect, free of every imperfection.","المنزّه عن كل نقص وعيب.","quran","majesty"),
("al-qadeer",53,"القدير","Al-Qadeer","The All-Powerful","القدير","The All-Powerful over everything.","القدير على كل شيء.","quran","power"),
("al-qareeb",54,"القريب","Al-Qareeb","The Near","القريب","The One near to His servants.","القريب من عباده.","quran","mercy"),
("al-qawiyy",55,"القوي","Al-Qawiyy","The Most Strong","القوي","The One perfect in strength.","القوي الذي لا يعجزه شيء.","quran","power"),
("al-qahhaar",56,"القهار","Al-Qahhaar","The Overwhelming","القهار","The Overwhelming Subduer Who is never overcome.","القهار الذي لا يُغلب.","quran","power"),
("al-kabeer",57,"الكبير","Al-Kabeer","The Most Great","الكبير","The Incomparably Great.","الكبير الذي لا شيء أكبر منه.","quran","majesty"),
("al-kareem",58,"الكريم","Al-Kareem","The Most Generous","الكريم","The Bountiful, abundant in good.","الكريم كثير الخير والإحسان.","quran","mercy"),
("al-lateef",59,"اللطيف","Al-Lateef","The Most Subtle","اللطيف","The Subtle and Kind in ways His servants may not perceive.","اللطيف بعباده في خفاء ورفق.","quran","mercy"),
("al-mumin",60,"المؤمن","Al-Mu'min","The Granter of security","المؤمن","The True and Trustworthy, Granter of security.","الذي يصدق وعده ويؤمّن عباده.","quran","protection"),
("al-mutaali",61,"المتعالي","Al-Muta'aalee","The Supreme","المتعالي","The Supreme and Exalted One.","المتعالي عن كل نقص.","quran","majesty"),
("al-mutakabbir",62,"المتكبر","Al-Mutakabbir","The Supreme in Glory","المتكبر","The One rightfully proud, Supreme in Glory.","المستحق للكبرياء والعظمة.","quran","majesty"),
("al-mateen",63,"المتين","Al-Mateen","The Firm","المتين","The Strong Whose strength does not weaken.","الشديد القوة الذي لا تضعف قوته.","quran","power"),
("al-mujeeb",64,"المجيب","Al-Mujeeb","The Responsive","المجيب","The One Who answers the call of those who call upon Him.","الذي يجيب دعوة الداعين.","quran","mercy"),
("al-majeed",65,"المجيد","Al-Majeed","The Glorious","المجيد","The One Perfect in Glory and Honour.","المجيد ذو المجد والكرم.","quran","majesty"),
("al-muheet",66,"المحيط","Al-Muheet","The All-Encompassing","المحيط","The One Whose knowledge and power encompass all things.","الذي أحاط بكل شيء علماً وقدرة.","quran","knowledge"),
("al-musawwir",67,"المصور","Al-Musawwir","The Fashioner","المصور","The Bestower of forms and shapes.","الذي يصوّر الخلق كيف يشاء.","quran","creation"),
("al-muqtadir",68,"المقتدر","Al-Muqtadir","The Omnipotent","المقتدر","The One Whose power is perfect and effective.","القادر قدرة تامة نافذة.","quran","power"),
("al-muqeet",69,"المقيت","Al-Muqeet","The Sustainer","المقيت","The All-Powerful Maintainer Who provides what is needed.","الذي يقوت الخلق ويقدر أقواتهم.","quran","provision"),
("al-malik",70,"الملك","Al-Malik","The King","الملك","The King and Owner of all dominion.","الملك مالك الملك.","quran","majesty"),
("al-maleek",71,"المليك","Al-Maleek","The Sovereign","المليك","The Omnipotent Sovereign.","المليك ذو الملك العظيم.","quran","majesty"),
("al-mawlaa",72,"المولى","Al-Mawlaa","The Protecting Lord","المولى","The Patron, Master, and Supporter.","المولى الناصر والمعين.","quran","protection"),
("al-muhaymin",73,"المهيمن","Al-Muhaymin","The Watchful Witness","المهيمن","The Trustworthy and Ever-Watchful Witness.","الرقيب الشاهد على خلقه.","quran","protection"),
("an-naseer",74,"النصير","An-Naseer","The Helper","النصير","The Helper Who grants victory to whom He wills.","النصير الذي ينصر أولياءه.","quran","protection"),
("al-waahid",75,"الواحد","Al-Waahid","The One","الواحد","The One and Only, without partner.","الواحد الذي لا شريك له.","quran","oneness"),
("al-waarith",76,"الوارث","Al-Waarith","The Inheritor","الوارث","The Inheritor Who remains after all creation.","الوارث الباقي بعد فناء الخلق.","quran","majesty"),
("al-waasi",77,"الواسع","Al-Waasi'","The Vast","الواسع","The Vast One in mercy, provision, and knowledge.","الواسع الرحمة والرزق والعلم.","quran","provision"),
("al-wadood",78,"الودود","Al-Wadood","The Loving","الودود","The Loving One Who loves His righteous servants.","الودود المحب لأوليائه.","quran","mercy"),
("al-wakeel",79,"الوكيل","Al-Wakeel","The Disposer of affairs","الوكيل","The Trustworthy Disposer of affairs.","الوكيل الكفيل بتدبير الأمور.","quran","protection"),
("al-waliyy",80,"الولي","Al-Waliyy","The Guardian","الولي","The Guardian Lord of the believers.","ولي المؤمنين ونصيرهم.","quran","protection"),
("al-wahhaab",81,"الوهاب","Al-Wahhaab","The Bestower","الوهاب","The Bestower of gifts without being asked in return.","الوهاب كثير الهبات والعطايا.","quran","provision"),
("al-jameel",82,"الجميل","Al-Jameel","The Beautiful","الجميل","The Beautiful One; beauty belongs to Him perfectly.","الجميل في ذاته وصفاته.","sunnah","majesty"),
("al-jawaad",83,"الجواد","Al-Jawaad","The Munificent","الجواد","The Munificent, generous in giving.","الجواد الكريم العطاء.","sunnah","mercy"),
("al-hakam",84,"الحكم","Al-Hakam","The Judge","الحكم","The Judge Whose judgment is perfect.","الحكم الذي يقضي بالحق.","sunnah","knowledge"),
("al-hayiyy",85,"الحيي","Al-Hayiyy","The Modest","الحيي","The One Who honourably refrains from what does not befit His generosity.","الحيي الذي يستحي أن يرد عبده خائباً.","sunnah","mercy"),
("ar-rabb",86,"الرب","Ar-Rabb","The Lord","الرب","The Lord and Nurturer of all creation.","رب العالمين مربيهم ومدبرهم.","sunnah","majesty"),
("ar-rafeeq",87,"الرفيق","Ar-Rafeeq","The Gentle","الرفيق","The Gentle One Who loves gentleness.","الرفيق الذي يحب الرفق.","sunnah","mercy"),
("as-subbooh",88,"السبوح","As-Subbooh","The Perfect","السبوح","The One free of every imperfection, worthy of glorification.","المنزّه عن كل نقص، المستحق للتسبيح.","sunnah","majesty"),
("as-sayyid",89,"السيد","As-Sayyid","The Master","السيد","The Lord and Master.","السيد الذي يسود خلقه.","sunnah","majesty"),
("ash-shaafee",90,"الشافي","Ash-Shaafee","The Healer","الشافي","The One Who cures.","الشافي من الأمراض والأسقام.","sunnah","mercy"),
("at-tayyib",91,"الطيب","At-Tayyib","The Pure","الطيب","The Pure One; He accepts only what is pure.","الطيب الذي لا يقبل إلا طيباً.","sunnah","majesty"),
("al-qaabid",92,"القابض","Al-Qaabid","The Withholder","القابض","The One Who withholds provision as He wills.","الذي يقبض الرزق بحكمته.","sunnah","provision"),
("al-baasit",93,"الباسط","Al-Baasit","The Expander","الباسط","The One Who grants ample provision.","الذي يبسط الرزق لمن يشاء.","sunnah","provision"),
("al-muqaddim",94,"المقدم","Al-Muqaddim","The One Who brings forward","المقدم","The One Who gives precedence as He wills.","الذي يقدّم من يشاء بحكمته.","sunnah","majesty"),
("al-muakhkhir",95,"المؤخر","Al-Mu'akhkhir","The One Who puts back","المؤخر","The One Who delays and puts back as He wills.","الذي يؤخّر من يشاء بحكمته.","sunnah","majesty"),
("al-muhsin",96,"المحسن","Al-Muhsin","The Doer of good","المحسن","The One Who acts in a fine and excellent manner.","الذي يُحسن إلى خلقه.","sunnah","mercy"),
("al-mutee",97,"المعطي","Al-Mu'tee","The Giver","المعطي","The Giver Who grants to whom He wills.","المعطي لمن يشاء.","sunnah","provision"),
("al-mannaan",98,"المنان","Al-Mannaan","The Bestower of favours","المنان","The Beneficent Bestower of bounties.","المنان كثير المنّ والعطاء.","sunnah","provision"),
("al-witr",99,"الوتر","Al-Witr","The One","الوتر","The One Who has no partner nor anyone like Him.","الوتر الذي لا شريك له ولا مثيل.","sunnah","oneness"),
]

assert len(names) == 99

def esc(s: str) -> str:
    return s.replace("\\", "\\\\").replace("'", "\\'")

quran_note_en = "Included in Shaykh Ibn Uthaymeen's compilation of Names established in the Quran (Al-Qawa'id al-Muthla)."
quran_note_ar = "من الأسماء التي أوردها الشيخ ابن عثيمين مما ثبت في القرآن (القواعد المثلى)."
sunnah_note_en = "Included in Shaykh Ibn Uthaymeen's compilation of Names established in the authentic Sunnah (Al-Qawa'id al-Muthla)."
sunnah_note_ar = "من الأسماء التي أوردها الشيخ ابن عثيمين مما ثبت في السنة الصحيحة (القواعد المثلى)."

lines = []
lines.append("import '../models/asma.dart';")
lines.append("")
lines.append("/// Names of Allah collection for Al Noor.")
lines.append("///")
lines.append("/// Source: Shaykh Muhammad ibn Salih al-Uthaymeen, Al-Qawa'id al-Muthla:")
lines.append("/// 81 Names from the Quran and 18 from the authentic Sunnah.")
lines.append("/// English glosses follow the brief meanings taught with that list")
lines.append("/// (Dawud Burbank transcription). This is one scholarly compilation,")
lines.append("/// not a claim that the prophetic promise is limited to these exact Names,")
lines.append("/// and it is not the disputed enumeration attached to some Tirmidhi wordings.")
lines.append("class AsmaUlHusna {")
lines.append("  AsmaUlHusna._();")
lines.append("")
lines.append("  static const attributionEn =")
lines.append("      'Collection: Ibn Uthaymeen\\'s Al-Qawa\\'id al-Muthla (81 Quranic, 18 Sunnah). '")
lines.append("      'The authentic hadith in Bukhari and Muslim affirms ninety-nine Names without '")
lines.append("      'listing them. The popular ordered list linked to some Tirmidhi narrations is '")
lines.append("      'not treated here as an authenticated prophetic enumeration. Meanings are brief '")
lines.append("      'lexical/theological glosses for learning—not exhaustive creed treatises.';")
lines.append("")
lines.append("  static const attributionAr =")
lines.append("      'المصدر: القواعد المثلى للشيخ ابن عثيمين (٨١ من القرآن و١٨ من السنة). '")
lines.append("      'حديث البخاري ومسلم يثبت أن لله تسعة وتسعين اسماً دون سردها. القائمة الشهيرة '")
lines.append("      'المنسوبة لبعض روايات الترمذي لا تُعرض هنا كسرد نبوي ثابت. المعاني مختصرة للتعليم.';")
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
    lines.append(f"    AsmaTheme(id: '{tid}', nameEn: '{en}', nameAr: '{ar}'),")
lines.append("  ];")
lines.append("")
lines.append("  static const all = <DivineName>[")

for (nid, idx, arabic, tr, men, mar, exen, exar, src, theme) in names:
    note_en = quran_note_en if src == "quran" else sunnah_note_en
    note_ar = quran_note_ar if src == "quran" else sunnah_note_ar
    kind = "AsmaSourceKind.quran" if src == "quran" else "AsmaSourceKind.sunnah"
    lines.append("    DivineName(")
    lines.append(f"      id: '{nid}',")
    lines.append(f"      index: {idx},")
    lines.append(f"      arabic: '{arabic}',")
    lines.append(f"      transliteration: '{esc(tr)}',")
    lines.append(f"      meaningEn: '{esc(men)}',")
    lines.append(f"      meaningAr: '{esc(mar)}',")
    lines.append(f"      explanationEn: '{esc(exen)}',")
    lines.append(f"      explanationAr: '{esc(exar)}',")
    lines.append(f"      sourceKind: {kind},")
    lines.append(f"      evidenceNoteEn: '{esc(note_en)}',")
    lines.append(f"      evidenceNoteAr: '{esc(note_ar)}',")
    lines.append(f"      themeIds: ['{theme}'],")
    lines.append("    ),")

lines.append("  ];")
lines.append("")
lines.append("""  static DivineName? byId(String id) {
    for (final name in all) {
      if (name.id == id) return name;
    }
    return null;
  }

  static AsmaTheme? themeById(String id) {
    for (final theme in themes) {
      if (theme.id == id) return theme;
    }
    return null;
  }

  static List<DivineName> search({
    String query = '',
    String? themeId,
    AsmaSourceKind? sourceKind,
    bool favoritesOnly = false,
    Set<String> favoriteIds = const {},
  }) {
    final trimmed = query.trim().toLowerCase();
    return [
      for (final name in all)
        if ((!favoritesOnly || favoriteIds.contains(name.id)) &&
            (themeId == null || name.themeIds.contains(themeId)) &&
            (sourceKind == null || name.sourceKind == sourceKind) &&
            (trimmed.isEmpty || _matches(name, trimmed)))
          name,
    ];
  }

  static bool _matches(DivineName name, String query) {
    final haystack = [
      name.arabic,
      name.transliteration,
      name.meaningEn,
      name.meaningAr,
      name.explanationEn,
      name.explanationAr,
      name.id,
      '${name.index}',
    ].join(' ').toLowerCase();
    return haystack.contains(query);
  }

  static List<DivineName> related(DivineName name, {int limit = 6}) {
    final sameTheme = <DivineName>[];
    final sameSource = <DivineName>[];
    for (final other in all) {
      if (other.id == name.id) continue;
      final sharedTheme =
          other.themeIds.any((theme) => name.themeIds.contains(theme));
      if (sharedTheme) {
        sameTheme.add(other);
      } else if (other.sourceKind == name.sourceKind) {
        sameSource.add(other);
      }
    }
    return [...sameTheme, ...sameSource].take(limit).toList();
  }

  static List<String> quizOptions(DivineName correct, {int count = 4}) {
    final pool = [
      for (final name in all)
        if (name.id != correct.id) name.meaningEn,
    ]..shuffle();
    final options = [correct.meaningEn, ...pool.take(count - 1)];
    options.shuffle();
    return options;
  }
}
""")

out = Path(r"c:\DEV\Back to pray _update\lib\data\asma_ul_husna.dart")
out.write_text("\n".join(lines), encoding="utf-8")
print(f"wrote {len(names)} names to {out}")
