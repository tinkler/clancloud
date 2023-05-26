// Code generated by github.com/tinkler/mqttadmin; DO NOT EDIT.
import '../../http.dart';
import './const.dart';


class Member {
	
	int id = 0;
	
	String name = "";
	
	String surname = "";
	
	String nationality = "";
	
	int sex = 0;
	
	String birthRecordsPrefix = "";
	
	String birthRecords = "";
	
	String birthPlace = "";
	
	String qualifications = "";
	
	int contribution = 0;
	
	int rank = 0;
	
	String introduction = "";
	
	int recognizaedGeneration = 0;
	
	int isMarray = 0;
	
	int isAlive = 0;
	
	String profilePicture = "";
	
	Member? spouse;
	
	List<Member> spouses = [];
	
	Member? father;
	
	List<Member> children = [];
	
	Future<void> getById(
		int fdep,
		int cdep,
		
	) async {
		var response = await D.instance.dio.post('$modelUrlPrefix/clan/member/get-by-id', data: {
			"data": toJson(),
			"args": { "fdep": fdep,"cdep": cdep, }
		});
		if (response.data['code'] == 0) {
			var respModel = Member.fromJson(response.data['data']['data']);
			assign(respModel);
			
		}
		
	}
	Future<List<Member>> searchMember(
		String match,
		
	) async {
		var response = await D.instance.dio.post('$modelUrlPrefix/clan/member/search-member', data: {
			"data": toJson(),
			"args": { "match": match, }
		});
		if (response.data['code'] == 0) {
			var respModel = Member.fromJson(response.data['data']['data']);
			assign(respModel);
			if (response.data['data']['resp'] != null) {
				return (response.data['data']['resp'] as List<dynamic>).map((e) => Member.fromJson(e)).toList();
			} else {
				return [];
			}
			
		}
		return [];
		
	}
	
	Member();

	assign(Member other) {
		
		id = other.id;
		
		name = other.name;
		
		surname = other.surname;
		
		nationality = other.nationality;
		
		sex = other.sex;
		
		birthRecordsPrefix = other.birthRecordsPrefix;
		
		birthRecords = other.birthRecords;
		
		birthPlace = other.birthPlace;
		
		qualifications = other.qualifications;
		
		contribution = other.contribution;
		
		rank = other.rank;
		
		introduction = other.introduction;
		
		recognizaedGeneration = other.recognizaedGeneration;
		
		isMarray = other.isMarray;
		
		isAlive = other.isAlive;
		
		profilePicture = other.profilePicture;
		
		spouse = other.spouse;
		
		spouses = other.spouses;
		
		father = other.father;
		
		children = other.children;
		
	}

	Map<String, dynamic> toJson() {
		return {
			
			"id": id,
			
			"name": name,
			
			"surname": surname,
			
			"nationality": nationality,
			
			"sex": sex,
			
			"birth_records_prefix": birthRecordsPrefix,
			
			"birth_records": birthRecords,
			
			"birth_place": birthPlace,
			
			"qualifications": qualifications,
			
			"contribution": contribution,
			
			"rank": rank,
			
			"introduction": introduction,
			
			"recognizaed_generation": recognizaedGeneration,
			
			"is_marray": isMarray,
			
			"is_alive": isAlive,
			
			"profile_picture": profilePicture,
			
			"spouse": spouse != null ? spouse!.toJson() : null,
			
			"spouses": spouses.map((e) => e.toJson()).toList(),
			
			"father": father != null ? father!.toJson() : null,
			
			"children": children.map((e) => e.toJson()).toList(),
			
		};
	}
	Member.fromJson(Map<String, dynamic> json) {
		
		id = json["id"];
		
		name = json["name"];
		
		surname = json["surname"];
		
		nationality = json["nationality"];
		
		sex = json["sex"];
		
		birthRecordsPrefix = json["birth_records_prefix"];
		
		birthRecords = json["birth_records"];
		
		birthPlace = json["birth_place"];
		
		qualifications = json["qualifications"];
		
		contribution = json["contribution"];
		
		rank = json["rank"];
		
		introduction = json["introduction"];
		
		recognizaedGeneration = json["recognizaed_generation"];
		
		isMarray = json["is_marray"];
		
		isAlive = json["is_alive"];
		
		profilePicture = json["profile_picture"];
		
		spouse = json["spouse"] == null ? Member() : Member.fromJson(json["spouse"]);
		
		spouses = json["spouses"] == null ? [] : (json["spouses"] as List<dynamic>).map((e) => Member.fromJson(e)).toList();
		
		father = json["father"] == null ? Member() : Member.fromJson(json["father"]);
		
		children = json["children"] == null ? [] : (json["children"] as List<dynamic>).map((e) => Member.fromJson(e)).toList();
		
	}
}

class User {
	
	String id = "";
	
	String username = "";
	
	String nickname = "";
	
	int sex = 0;
	
	String avatarUrl = "";
	
	int memberId = 0;
	
	List<String> roles = [];
	
	Future<void> save(
		
	) async {
		var response = await D.instance.dio.post('$modelUrlPrefix/clan/user/save', data: {
			"data": toJson(),
			"args": {  }
		});
		if (response.data['code'] == 0) {
			var respModel = User.fromJson(response.data['data']['data']);
			assign(respModel);
			
		}
		
	}
	Future<void> load(
		
	) async {
		var response = await D.instance.dio.post('$modelUrlPrefix/clan/user/load', data: {
			"data": toJson(),
			"args": {  }
		});
		if (response.data['code'] == 0) {
			var respModel = User.fromJson(response.data['data']['data']);
			assign(respModel);
			
		}
		
	}
	
	User();

	assign(User other) {
		
		id = other.id;
		
		username = other.username;
		
		nickname = other.nickname;
		
		sex = other.sex;
		
		avatarUrl = other.avatarUrl;
		
		memberId = other.memberId;
		
		roles = other.roles;
		
	}

	Map<String, dynamic> toJson() {
		return {
			
			"id": id,
			
			"username": username,
			
			"nickname": nickname,
			
			"sex": sex,
			
			"avatar_url": avatarUrl,
			
			"member_id": memberId,
			
			"roles": roles,
			
		};
	}
	User.fromJson(Map<String, dynamic> json) {
		
		id = json["id"];
		
		username = json["username"];
		
		nickname = json["nickname"];
		
		sex = json["sex"];
		
		avatarUrl = json["avatar_url"];
		
		memberId = json["member_id"];
		
		roles = json["roles"] == null ? [] : (json["roles"] as List<dynamic>).map((e) => e as String).toList();
		
	}
}


