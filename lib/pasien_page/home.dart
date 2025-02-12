import 'package:coba/pasien_page/consultation.dart';
import 'package:coba/pasien_page/medical_record.dart';
import 'package:coba/pasien_page/profile.dart';
import 'package:coba/pasien_page/schedule_selection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required String username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2;
  String? _selectedEmotion;
  String username = "";

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'] ?? user.displayName ?? 'User';  
        });
      } else {
        setState(() {
          username = user.displayName ?? 'User';  
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onEmotionSelected(String emotion) {
    setState(() {
      _selectedEmotion = emotion;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      ProfilePage(username: '', email: ''), // Updated to use the fetched data
      ScheduleSelection(),
      const HomePage(username: ''), // HomePage widget without constructor parameters
      const MedicalRecordPage(),
      ConsultationScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'MindCare',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5EA8A7), fontSize: 35),
            ),
            Image.asset(
              'assets/logo.png',
              height: 70,
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: _selectedIndex == 2 ? _buildHomeContent() : pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Consul',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 38, 197, 194),
        onTap: _onItemTapped,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHomeContent() {
    final List<Map<String, String>> articles = [
      {
        "title": "Apa itu Kesehatan Mental?",
        "image": "assets/article1.png",
        "content":
            "Kesehatan jiwa atau sebutan lainnya kesehatan mental adalah kesehatan yang berkaitan dengan kondisi emosi, kejiwaan, dan psikis seseorang."
            "\n\nPerlu kamu ketahui bahwa peristiwa dalam hidup yang berdampak besar pada kepribadian dan perilaku seseorang bisa berpengaruh pada kesehatan mentalnya."
            "Misalnya, pelecehan saat usia dini, stres berat dalam jangka waktu lama tanpa adanya penanganan, dan mengalami kekerasan dalam rumah tangga."
            "Berbagai kondisi tersebut bisa membuat kondisi kejiwaan seseorang terganggu, sehingga muncul gejala gangguan kesehatan jiwa."
            "\n\nAkan tetapi, masalah kesehatan mental bisa mengubah cara seseorang dalam mengatasi stres, berhubungan dengan orang lain, membuat pilihan, dan memicu hasrat untuk menyakiti diri sendiri."
            "Beberapa jenis gangguan mental yang umum terjadi antara lain depresi, gangguan bipolar, kecemasan, gangguan stres pasca trauma (PTSD), gangguan obsesif kompulsif (OCD), dan psikosis."
            "Selain itu, ada beberapa penyakit mental hanya terjadi pada jenis pengidap tertentu, seperti postpartum depression hanya menyerang ibu setelah melahirkan.",
      },
       {
        "title": "Pentingnya Menjaga Kesehatan Mental",
        "image": "assets/article2.png",
        "content":
            "Kesehatan mental adalah aspek penting dari kesejahteraan secara keseluruhan karena berpengaruh langsung terhadap cara seseorang berpikir, merasa, dan berperilaku."
            "Ketika kesehatan mental terjaga, seseorang lebih mampu menghadapi stres, menjaga hubungan yang sehat, dan membuat keputusan yang baik dalam kehidupannya."
            "Sebaliknya, masalah kesehatan mental yang tidak ditangani dapat berdampak buruk pada kualitas hidup, termasuk menurunnya produktivitas dan hubungan sosial."
            "Menjaga kesehatan mental juga penting karena dapat mencegah berbagai gangguan psikologis seperti depresi dan kecemasan."
            "Dengan menjalani pola hidup sehat, termasuk olahraga teratur, tidur yang cukup, dan menjaga keseimbangan antara pekerjaan dan kehidupan pribadi, seseorang dapat memperkuat kondisi mentalnya." 
            "Selain itu, berbicara dengan orang terpercaya atau profesional saat menghadapi masalah juga merupakan langkah penting dalam menjaga kesehatan mental."
      },
      {
        "title": "Penyebab Gangguan Kesehatan Mental",
        "image": "assets/article9.png",
        "content":
            "Ada beberapa kondisi yang bisa menjadi penyebab seseorang mengalami gangguan kesehatan jiwa, antara lain:"
            "\n1. Cedera pada kepala."
            "\n2. Faktor genetik atau terdapat riwayat pengidap gangguan kesehatan jiwa dalam keluarga."
            "\n3. Kekerasan dalam rumah tangga atau bentuk pelecehan lainnya."
            "\n4. Adanya riwayat kekerasan saat kanak-kanak."
            "\n5. Memiliki kelainan senyawa kimia otak atau gangguan pada otak."
            "\n6. Mengalami diskriminasi dan stigma."
            "\n7. Kehilangan atau kematian seseorang yang sangat dekat."
            "\n8. Mengalami kerugian sosial, seperti masalah kemiskinan atau utang."
            "\n9. Merawat anggota keluarga atau teman yang sakit kronis."
            "\n10. Pengangguran, kehilangan pekerjaan, atau tunawisma.",
      },
      {
        "title": "Faktor Resiko Gangguan Kesehatan Mental",
        "image": "assets/article4.png",
        "content":
            "Selain itu, ada beberapa faktor yang bisa meningkatkan risiko seseorang mengalami gangguan kesehatan jiwa, diantaranya yaitu:"
            "\n1. Wanita berisiko tinggi mengidap depresi dan kecemasan, sedangkan laki-laki memiliki risiko mengidap ketergantungan zat dan antisosial."
            "\n2. Wanita setelah melahirkan. Baca lebih lanjut artikel Mengenal 3 Jenis Depresi Pasca-Melahirkan untuk mengetahui apa saja jenis gangguan mental yang kerap terjadi pada ibu setelah melahirkan."
            "\n3. Adanya masalah pada masa kanak-kanak atau masalah gaya hidup."
            "\n4. Menjalani profesi yang memicu stres, seperti dokter dan pengusaha."
            "\n5. Memiliki riwayat anggota keluarga atau keluarga dengan penyakit mental."
            "\n6. Mempunyai riwayat kelahiran dengan kelainan pada otak."
            "\n7. Adanya riwayat penyakit mental sebelumnya."
            "\n8. Mengalami kegagalan dalam hidup, seperti sekolah atau kehidupan kerja."
            "\n9. Menyalahgunakan alkohol atau obat-obatan terlarang.",
      },
      {
        "title": "Gejala Gangguan Kesehatan Mental",
        "image": "assets/article5.png",
        "content":
            "Gejala gangguan kesehatan jiwa bisa berbeda bergantung pada jenisnya. Kendati demikian, gejala umum dari kelainan kesehatan ini yang bisa kamu kenali antara lain:"
            "\n1. Berteriak atau berkelahi dengan keluarga dan teman-teman."
            "\n2. Delusi, paranoia, atau halusinasi."
            "\n3. Kehilangan kemampuan untuk berkonsentrasi."
            "\n4. Ketakutan, kekhawatiran, atau perasaan bersalah yang selalu menghantui."
            "\n5. Ketidakmampuan untuk mengatasi stres atau masalah sehari-hari."
            "\n6. Marah berlebihan dan rentan melakukan kekerasan."
            "\n7. Memiliki pengalaman dan kenangan buruk yang tidak dapat dilupakan."
            "\n8. Adanya pikiran untuk menyakiti diri sendiri atau orang lain."
            "\n9. Menarik diri dari orang-orang dan kegiatan sehari-hari.",
      },
      {
        "title": "Diagnosis Gangguan Kesehatan Mental",
        "image": "assets/article6.png",
        "content":
            "Dokter ahli jiwa atau psikiater akan mengawali diagnosis gangguan kesehatan mental dengan wawancara medis dan psikiatri."
            "Mulanya, dokter akan bertanya mengenai riwayat gejala pada pengidap dan penyakit pada keluarga."
            "Kemudian, dokter akan melakukan pemeriksaan fisik untuk mengeliminasi kemungkinan adanya penyakit lain."
            "Jika memang perlu, dokter akan meminta pengidap untuk melakukan tindakan pemeriksaan penunjang, seperti pemeriksaan fungsi tiroid, skrining alkohol dan obat-obatan, serta CT scan untuk mengetahui adanya kelainan pada otak."
            "Sementara itu, jika tidak menemukan adanya potensi kondisi medis lain, dokter akan meresepkan obat dan terapi yang sesuai."
            "Kadang, mengikuti tes sederhana seperti depression test juga bisa membantu mengenali kondisi kesehatan mental."
            "Tetapi, kamu juga tidak boleh melakukan diagnosis sendiri terhadap kesehatan mental yang dialami.",
      },
      {
        "title": "Pengobatan Gangguan Kesehatan Mental",
        "image": "assets/article8.png",
        "content":
            "Ada beberapa cara penanganan gangguan kesehatan mental yang bisa menjadi pilihan sesuai dengan kondisi yang terjadi pada pengidap, yaitu:"
            "\n1. Psikoterapi"
            "\n2. Obat"
            "\n3. Perawatan intensif di rumah sakit"
            "\n4. Supporting group"
            "\n5. Stimulasi pada otak"
            "\n6. Rehabilitasi"
            "\n7. Perawatan mandiri",
      },
      {
        "title": "Pencegahan Gangguan Kesehatan Mental",
        "image": "assets/article7.png",
        "content":
            "Selain itu, kamu juga bisa melakukan beberapa upaya untuk mencegah terjadinya gangguan kesehatan jiwa antara lain:"
            "\n1. Melakukan aktivitas fisik dan tetap aktif secara fisik."
            "\n2. Membantu orang lain dengan tulus."
            "\n3. Membiasakan berpikir positif."
            "\n4. Memiliki kemampuan untuk mengatasi masalah."
            "\n5. Mencari bantuan profesional jika memang kamu memerlukannya."
            "\n6. Menjaga hubungan baik dengan orang lain."
            "\n7. Memastikan tubuh mendapatkan cukup waktu istirahat.",
      },
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF5EA8A7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang, $username!!!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Bagaimana perasaanmu saat ini?',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildEmotionIcon(Icons.sentiment_very_dissatisfied, 'Sangat\nSedih'),
                  _buildEmotionIcon(Icons.sentiment_dissatisfied, 'Sedih'),
                  _buildEmotionIcon(Icons.sentiment_neutral, 'Biasa\nSaja'),
                  _buildEmotionIcon(Icons.sentiment_satisfied, 'Senang'),
                  _buildEmotionIcon(Icons.sentiment_very_satisfied, 'Sangat\nSenang'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'MindStory',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5EA8A7),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2 / 3,
              ),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleDetailPage(
                          title: article["title"]!,
                          content: article["content"]!,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Image.asset(
                              article["image"]!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            article["title"]!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionIcon(IconData icon, String emotion) {
    return GestureDetector(
      onTap: () => _onEmotionSelected(emotion),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: _selectedEmotion == emotion ? Colors.black : Colors.white,
          ),
          const SizedBox(height: 4),
          Text(
            emotion,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  final String title;
  final String content;

  const ArticleDetailPage({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Color(0xFF5EA8A7),
      ),
      body: 
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          content,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
