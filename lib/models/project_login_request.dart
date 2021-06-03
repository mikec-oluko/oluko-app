class ProjectLoginRequest {
  ProjectLoginRequest({this.projectId});

  String projectId;

  ProjectLoginRequest.fromJson(Map json) : projectId = json['projectId'];

  Map<String, dynamic> toJson() => {
        'projectId': projectId,
      };
}
