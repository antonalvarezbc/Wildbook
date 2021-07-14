<%@ page contentType="text/html; charset=utf-8" language="java"
     import="org.ecocean.*,
java.util.Collection,
java.util.List,
java.util.ArrayList,
javax.jdo.*,
java.util.Arrays,
org.json.JSONObject,
java.lang.reflect.*,

org.ecocean.api.ApiCustomFields,
org.ecocean.customfield.*,

org.ecocean.media.*
              "
%>




<%

Shepherd myShepherd = new Shepherd("context0");
myShepherd.beginDBTransaction();

String fieldName = request.getParameter("fieldName");
String className = request.getParameter("className");
boolean commit = Util.requestParameterSet(request.getParameter("commit"));
if ((className == null) || (fieldName == null)) throw new RuntimeException("must pass className= and fieldName=");

Class cls = null;
switch (className) {
    case "Encounter":
        cls = Encounter.class;
        break;
    case "Occurrence":
        cls = Occurrence.class;
        break;
    case "MarkedIndividual":
        cls = MarkedIndividual.class;
}

if (cls == null) throw new RuntimeException("invalid className= passed");

Field field = cls.getDeclaredField(fieldName);

CustomFieldDefinition cfd = new CustomFieldDefinition(field);
out.println("<p>new cfd: <b>" + cfd + "</b></p>");
CustomFieldDefinition found = CustomFieldDefinition.find(myShepherd, cfd);
if (found != null) {
    out.println("<p>collision with existing cfd: <b>" + found + "</b></p>");
    myShepherd.rollbackDBTransaction();
    return;
}

if (!commit) {
    out.println("<hr /><p><b>commit=false</b>, not modifying anything</p>");
    myShepherd.rollbackDBTransaction();
    return;
}

String jdoql = "SELECT FROM org.ecocean." + className + " WHERE ";
if (cfd.getMultiple()) {
    jdoql += fieldName + ".size() > 0";
} else {
    jdoql += fieldName + " != null";
}
jdoql += " RANGE 0,10";

out.println("<p>jdoql = <b>" + jdoql + "</b></p><hr />");

myShepherd.getPM().makePersistent(cfd);

Query query = myShepherd.getPM().newQuery(jdoql);
Collection c = (Collection) (query.execute());
List<ApiCustomFields> all = new ArrayList<ApiCustomFields>(c);
query.closeAll();
for (ApiCustomFields obj : all) {
    Object val = obj.migrateFieldValue(cfd, field);
    out.println("<p>" + obj + "</p>");
}


myShepherd.commitDBTransaction();

%>



