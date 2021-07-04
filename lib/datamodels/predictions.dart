
class Prediction
{
  String placeId='';
  String mainText='';
  String secondaryText='';
  Prediction({this.placeId='',this.mainText='',this.secondaryText=''});
  Prediction.fromJson(Map<String, dynamic> json){
  this.placeId = json['place_id'].toString();
    this.mainText = json['structured_formatting']['main_text'].toString();
  this.secondaryText = json['structured_formatting']['secondary_text'].toString();
  }
}