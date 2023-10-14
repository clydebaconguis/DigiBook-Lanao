// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ict_ebook_hsa/app_util.dart';
import 'package:ict_ebook_hsa/signup_login/sign_in.dart';

class SimpleDropDown extends StatefulWidget {
  const SimpleDropDown({Key? key}) : super(key: key);

  @override
  State<SimpleDropDown> createState() => _SchoolSelectionPageState();
}

class _SchoolSelectionPageState extends State<SimpleDropDown> {
  String selectedSchool = '';
  int schoolIndex = 0;

  List<SchoolData> _filteredSchool = [];

  void _filterSchools(String query) {
    setState(() {
      if (query != '') {
        _filteredSchool = AppUtil()
            .schools
            .where((school) =>
                school.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        _filteredSchool = AppUtil().schools;
      }
    });
  }

  _toSignIn() {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignIn(schoolIndex),
        ),
      );
      // Navigator.of(context).pushAndRemoveUntil(
      //     MaterialPageRoute(
      //       builder: (context) => SignIn(schoolIndex),
      //     ),
      //     (Route<dynamic> route) => false);
    }
  }

  @override
  void initState() {
    _filterSchools('');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 60,
                  child: Image.asset('img/CK_logo.png'),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 0,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  color: Colors.grey.shade800,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Lanao School Members',
                                  style: GoogleFonts.workSans(
                                    color: Colors.grey.shade800,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          color: Colors.grey.shade300,
                          height: 1,
                          thickness: 1,
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: TextField(
                            style: GoogleFonts.workSans(
                                fontWeight: FontWeight.normal),
                            onChanged: _filterSchools,
                            decoration: InputDecoration(
                              labelText: 'Search School',
                              prefixIcon: const Icon(Icons.search),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                    color: Colors.grey
                                        .shade200), // Change the border color here
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                    color: Colors.grey
                                        .shade200), // Change the border color here
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              left: 12, right: 12, bottom: 10),
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _filteredSchool.length,
                            itemBuilder: (context, index) {
                              final school = _filteredSchool[index];

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedSchool = school.name;
                                  });
                                  // print(school.name);
                                  // print(index);
                                  schoolIndex = index;
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      color: Colors.transparent,
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            school.img,
                                            height: 30,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            school.name,
                                            style: GoogleFonts.workSans(
                                              fontWeight:
                                                  selectedSchool == school.name
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                              color:
                                                  selectedSchool == school.name
                                                      ? Colors.green.shade700
                                                      : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (selectedSchool.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: ElevatedButton(
                      onPressed: selectedSchool.isNotEmpty
                          ? () {
                              // print('success');
                              // print(selectedSchool);
                              _toSignIn();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 10,
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Proceed'),
                          SizedBox(width: 10),
                          Icon(
                            Icons.forward_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SchoolData {
  String name;
  String img;
  String domain;
  String abbv;
  String address;
  Color primary;

  SchoolData({
    required this.name,
    required this.img,
    required this.domain,
    required this.abbv,
    required this.primary,
    required this.address,
  });
}
