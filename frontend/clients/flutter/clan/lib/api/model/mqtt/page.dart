// Code generated by github.com/tinkler/mqttadmin; DO NOT EDIT.
import '../../http.dart';
import './const.dart';
import './user.dart' as $user show User;

class Page {
  int page = 0;

  int perPage = 0;

  int total = 0;

  Future<List<$user.User>> fetchUser() async {
    var response = await D.instance.dio.post(
        '$modelUrlPrefix/page/page/fetch-user',
        data: {"data": this, "args": {}});
    if (response.data['code'] == 0) {
      var respModel = Page.fromJson(response.data['data']['data']);
      assign(respModel);
      if (response.data['data']['resp'] != null) {
        return (response.data['data']['resp'] as List<dynamic>)
            .map((e) => $user.User.fromJson(e))
            .toList();
      } else {
        return [];
      }
    }
    return [];
  }

  Page();

  assign(Page other) {
    page = other.page;

    perPage = other.perPage;

    total = other.total;
  }

  Map<String, dynamic> toJson() {
    return {
      "page": page,
      "per_page": perPage,
      "total": total,
    };
  }

  Page.fromJson(Map<String, dynamic> json) {
    page = json["page"];

    perPage = json["per_page"];

    total = json["total"];
  }
}
