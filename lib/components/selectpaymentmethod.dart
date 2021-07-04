import 'package:flutter/material.dart';


class SelectPaymentMethod extends StatelessWidget {
  final String selectedvalue;
  final Function changePriority;
  SelectPaymentMethod(this.selectedvalue,this.changePriority);
  @override
  Widget build(BuildContext context) {
    //   Widget<DropdownButton> getDropDown(){
    return Container(
      height: MediaQuery.of(context).size.height * 0.07,
      child: DropdownButton<String>(items: [
        DropdownMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cash'),
              Icon(
                Icons.money,
              )
            ],
          ),
          value: 'Cash',
        ),
        DropdownMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Debit/Credit Card'),
              Icon(
                Icons.credit_card_rounded,
              )
            ],
          ),
          value: 'Debit/Credit Card',
        ),
        DropdownMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('UPI'),
              Icon(
                Icons.payments_rounded,
              )
            ],
          ),
          value: 'UPI',
        ),
      ],
        onChanged: (value) =>
          changePriority(value)
        ,
        value: selectedvalue,
      ),
    );
  }
// }
}

