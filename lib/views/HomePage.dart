import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/sqlite_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All journals
  List<Map<String, dynamic>> _database = [];

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshDatabase() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _database = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshDatabase(); // Loading the diary when the app starts
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  String _saldo() {
    var data;
    var saldo;
    var pengeluaran;
    List mentahanSaldo = [];
    List mentahanPengeluaran = [];
    for (var i = 0; i < _database.length; i++) {
      if (_database[i]['type'] == 'pemasukan') {
        var getData = _database[i]['amount'];
        mentahanSaldo.add(getData);
      } else if (_database[i]['type'] == 'pengeluaran') {
        var getData = _database[i]['amount'];
        mentahanPengeluaran.add(getData);
      }
    }

    setState(() {
      saldo = mentahanSaldo.isEmpty
          ? saldo = 0
          : mentahanSaldo.reduce((value, element) => value + element);
      pengeluaran = mentahanPengeluaran.isEmpty
          ? pengeluaran = 0
          : mentahanPengeluaran.reduce((value, element) => value + element);
      data = saldo - pengeluaran;
    });
    return data.toString();
  }

  String _income() {
    var pendapatan;
    List mentahanSaldo = [];
    List mentahanPengeluaran = [];
    for (var i = 0; i < _database.length; i++) {
      if (_database[i]['type'] == 'pemasukan') {
        var getData = _database[i]['amount'];
        mentahanSaldo.add(getData);
      } else if (_database[i]['type'] == 'pengeluaran') {
        var getData = _database[i]['amount'];
        mentahanPengeluaran.add(getData);
      }
    }

    setState(() {
      pendapatan = mentahanSaldo.isEmpty
          ? pendapatan = 0
          : mentahanSaldo.reduce((value, element) => value + element);
    });
    return pendapatan.toString();
  }

  String _outcome() {
    var pengeluaran;
    List mentahanSaldo = [];
    List mentahanPengeluaran = [];
    for (var i = 0; i < _database.length; i++) {
      if (_database[i]['type'] == 'pemasukan') {
        var getData = _database[i]['amount'];
        mentahanSaldo.add(getData);
      } else if (_database[i]['type'] == 'pengeluaran') {
        var getData = _database[i]['amount'];
        mentahanPengeluaran.add(getData);
      }
    }

    setState(() {
      pengeluaran = mentahanPengeluaran.isEmpty
          ? pengeluaran = 0
          : mentahanPengeluaran.reduce((value, element) => value + element);
    });
    return pengeluaran.toString();
  }

  String _convertTime(DateTime data) {
    var push;
    final DateFormat formatter = DateFormat('MM/dd/yyyy, hh:mm a');
    push = formatter.format(data);
    return push.toString();
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingDatabase =
          _database.firstWhere((element) => element['id'] == id);
      _titleController.text = existingDatabase['title'];
      _amountController.text = existingDatabase['amount'].toString();
      _typeController.text = existingDatabase['type'];
      _descriptionController.text = existingDatabase['description'];
    }
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(7.0))),
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 8.0,
                  ),
                  Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(hintText: 'Judul'),
                      ),
                      TextField(
                        controller: _amountController,
                        decoration: const InputDecoration(hintText: 'Jumlah'),
                      ),
                      TextField(
                        controller: _typeController,
                        decoration: const InputDecoration(hintText: 'Tipe'),
                      ),
                      TextField(
                        controller: _descriptionController,
                        decoration:
                            const InputDecoration(hintText: 'Keterangan'),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Center(
                          child: Container(
                            height: 50,
                            margin: const EdgeInsets.only(bottom: 10, top: 15),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60.0),
                            ),
                            // ignore: deprecated_member_use
                            child: RaisedButton(
                              onPressed: () async {
                                if (id == null) {
                                  await _addItem();
                                }

                                if (id != null) {
                                  await _updateItem(id);
                                }
                                Navigator.of(context).pop();
                              },
                              color: Colors.blue[700],
                              child: Text(id == null ? 'Submit' : 'Update',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Quattro',
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.017)),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ));
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted'),
    ));
    _refreshDatabase();
  }

  Future<void> _addItem() async {
    await SQLHelper.createItem(_titleController.text, _amountController.text,
        _typeController.text, _descriptionController.text);
    _refreshDatabase();
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
      id,
      _titleController.text,
      _amountController.text,
      _typeController.text,
      _descriptionController.text,
    );
    _refreshDatabase();
  }

  Widget _home() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 1.1,
              height: MediaQuery.of(context).size.height / 6,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                  color: Colors.cyan[300]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        'Eka Mahendra',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Saldo Rp${_saldo()}',
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Icon(Icons.north_east, color: Colors.green)
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Income',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w300),
                              ),
                              Text(
                                'Rp${_income()}',
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Column(
                            children: [
                              Icon(Icons.south_west, color: Colors.red)
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Outcome',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w300),
                              ),
                              Text(
                                'Rp${_outcome()}',
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    'History Data',
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.black87,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: ListView.builder(
                        itemCount: _database.length,
                        itemBuilder: (context, index) => Card(
                            color: Colors.blue[200],
                            margin: const EdgeInsets.symmetric(
                                vertical: 7, horizontal: 18),
                            child: Container(
                              height: 70,
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _database[index]['title'],
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w800),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${_database[index]['description']}',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            _convertTime(DateTime.parse(
                                                _database[index]['createdAt'])),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black38,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                          onTap: () =>
                                              _showForm(_database[index]['id']),
                                          child: Container(
                                              child: Icon(Icons.edit,
                                                  color: Colors.blue,
                                                  size: 20))),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      GestureDetector(
                                          onTap: () => _deleteItem(
                                              _database[index]['id']),
                                          child: Container(
                                              child: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ))),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget initHome() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _home(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showForm(null);
          _titleController.text = '';
          _amountController.text = '';
          _typeController.text = '';
          _descriptionController.text = '';
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: initHome(),
    );
  }
}
