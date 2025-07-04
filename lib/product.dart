import 'dart:convert' as convert;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//main URL for REST pages
const String _baseURL = 'csci410fall2023.atwebpages.com';

//class to represent a row from the products table
//note: cid is replaced by category name

class Product{
  int _pid;
  String _name;
  int _quantity;
  double _price;
  String _category;

  Product(this._pid, this._name, this._quantity, this._price, this._category);

  @override
  String toString() {
    return 'Product{_pid: $_pid, _name: $_name, _quantity: $_quantity, _price: \$$_price, _category: $_category}';
  }
}

//list to hold products retrieved from products
List<Product> _products=[];

//asynchronously update product list
void updateProducts (Function(bool success) update)async{
  try{
    final url=Uri.http(_baseURL,'getProducts.php');
    //the php page
    final response=await http.get(url).timeout(const Duration(seconds: 30));//max timeout 5 seconds
    //clear old products
    _products.clear();
    //200 is a succuseful call
    if(response.statusCode==200){
      // tranform the php page body from json array to "create dart json object"
      final jsonResponse=convert.jsonDecode(response.body);
      //iterating over the dart json object
      for(var row in jsonResponse){
        //create a product from the json dart
        Product p=Product(
            int.parse(row['pid']),
            row['name'],
            int.parse(row['quantity']),
            double.parse(row['price']),
            row['category']
        );
        //add the product object to the _products list
        _products.add(p);
      }
      //callback the the update method to inform that we completed retrieving data
      update(true);
    }
  }catch(e){
    //inform through callback that we failed to get data
    update(false);
  }
}

// searches for a single product using product pid
void searchProduct(Function(String text) update, int pid) async {
  try {
    final url = Uri.http(_baseURL, 'searchProduct.php', {'pid':'$pid'});
    final response = await http.get(url)
        .timeout(const Duration(seconds: 30));
    _products.clear();
    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      var row = jsonResponse[0];
      Product p = Product(
          int.parse(row['pid']),
          row['name'],
          int.parse(row['quantity']),
          double.parse(row['price']),
          row['category']);
      _products.add(p);
      update(p.toString());
    }
  }
  catch(e) {
    update("can't load data");
  }
}


class ShowProducts extends StatelessWidget {
  const ShowProducts({super.key});

  @override
  Widget build(BuildContext context) {
    double width=MediaQuery.of(context).size.width;
    return ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context,index)=>Column(
          children: [
            const SizedBox(height: 10,),
            Container(
              color: index%2==0 ?Colors.amber : Colors.cyan,
              //5 logical pixels
              padding: const EdgeInsets.all(5),
              width: width*0.9,child:Row(
              children: [
                SizedBox(width: width*0.15,),
                Flexible(child: Text(_products[index].toString(),style: TextStyle(fontSize:width*0.045),))
              ],
            ),

            )
          ],
        ));
  }
}
