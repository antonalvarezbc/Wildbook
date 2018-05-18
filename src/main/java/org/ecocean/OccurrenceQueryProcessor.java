package org.ecocean;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Vector;
import java.io.*;

import javax.jdo.Query;
import javax.servlet.http.HttpServletRequest;

import org.ecocean.*;
import org.ecocean.servlet.ServletUtilities;
import org.ecocean.security.Collaboration;

import org.joda.time.DateTime;

public class OccurrenceQueryProcessor extends QueryProcessor {

  private static final String BASE_FILTER = "SELECT FROM org.ecocean.Occurrence WHERE \"ID\" != null && ";

  public static final String[] SIMPLE_STRING_FIELDS = new String[]{"ID","distance","groupBehavior","sightNo"};

  

  public static String queryStringBuilder(HttpServletRequest request, StringBuffer prettyPrint, Map<String, Object> paramMap){

    String filter= BASE_FILTER;
    String jdoqlVariableDeclaration = "";
    String parameterDeclaration = "";
    String context="context0";
    context=ServletUtilities.getContext(request);

    Shepherd myShepherd=new Shepherd(context);
    //myShepherd.setAction("OccurrenceQueryProcessor.class");

    //filter for id------------------------------------------
    filter = QueryProcessor.filterWithBasicStringField(filter, "id", request, prettyPrint);
    System.out.println("           beginning filter = "+filter);

    // filter for simple string fields
    for (String fieldName : SIMPLE_STRING_FIELDS) {
      System.out.println("   parsing occurrence query for field "+fieldName);
      System.out.println("           current filter = "+filter);
      filter = QueryProcessor.filterWithBasicStringField(filter, fieldName, request, prettyPrint);
    }

    // Date contraints if present
    filter = occurrenceDateRange(request, filter, prettyPrint);
    
    // GPS box
    filter = QueryProcessor.filterWithGpsBox(filter, request, prettyPrint);
    
    
    //Observations
    filter = QueryProcessor.filterObservations(filter, request, prettyPrint, "Occurrence");
    int numObs = QueryProcessor.getNumberOfObservationsInQuery(request);
    for (int i = 1;i<=numObs;i++) {
      jdoqlVariableDeclaration = QueryProcessor.updateJdoqlVariableDeclaration(jdoqlVariableDeclaration, "org.ecocean.Observation observation" + i);      
    }
    
    // make sure no trailing ampersands
    filter = QueryProcessor.removeTrailingAmpersands(filter);
    filter += jdoqlVariableDeclaration;
    filter += parameterDeclaration;
    System.out.println("OccurrenceQueryProcessor filter: "+filter);
    return filter;
  }

  public static OccurrenceQueryResult processQuery(Shepherd myShepherd, HttpServletRequest request, String order){

    Vector<Occurrence> rOccurrences=new Vector<Occurrence>();
    Iterator<Occurrence> allOccurrences;
    String filter="";
    StringBuffer prettyPrint=new StringBuffer("");
    Map<String,Object> paramMap = new HashMap<String, Object>();

    filter=queryStringBuilder(request, prettyPrint, paramMap);
    System.out.println("OccurrenceQueryResult: has filter "+filter);
    Query query=myShepherd.getPM().newQuery(filter);
    System.out.println("                       got query "+query);
    System.out.println("                       has paramMap "+paramMap);
    if(!order.equals("")){query.setOrdering(order);}
    System.out.println("                 still has query "+query);
    if(!filter.trim().equals("")){
      System.out.println(" about to call myShepherd.getAllOccurrences on query "+query);
      allOccurrences=myShepherd.getAllOccurrences(query, paramMap);
    } else {
      System.out.println(" about to call myShepherd.getAllOccurrencesNoQuery() ");
      allOccurrences=myShepherd.getAllOccurrencesNoQuery();
    }
    System.out.println("               *still* has query "+query);


    if(allOccurrences!=null){
      while (allOccurrences.hasNext()) {
        Occurrence temp_dat=allOccurrences.next();
        rOccurrences.add(temp_dat);
      }
    }
  	query.closeAll();

    System.out.println("about to return OccurrenceQueryResult with filter "+filter+" and nOccs="+rOccurrences.size());
    return (new OccurrenceQueryResult(rOccurrences,filter,prettyPrint.toString()));
  }
  
 public static String prepForNext(String filter) {
   if (!QueryProcessor.endsWithAmpersands(filter)) {
     QueryProcessor.prepForCondition(filter);
   }
   System.out.println("Prep for next? Here's the filter: "+filter);
   return filter;
 }


 protected static String occurrenceDateRange(HttpServletRequest request, String filter, StringBuffer prettyPrint) {
  String endTime = null;
  String startTime = null;
  
  try {
    filter = prepForCondition(filter);
    if (request.getParameter("startTime")!=null&&request.getParameter("startTime").length()>8) {
      startTime = monthDayYearToMilli(request.getParameter("startTime"));
      // Crush date
      String addition = " (millis >= "+startTime+") ";
      prettyPrint.append(addition);
      filter += addition;
    }      
  } catch (NullPointerException npe) {
    npe.printStackTrace();
  }
  
  try {
    filter = prepForCondition(filter);
    if (request.getParameter("endTime")!=null&&request.getParameter("endTime").length()>8) {
      endTime = monthDayYearToMilli(request.getParameter("endTime"));
      // Crush date
      String addition = " (millis <= "+endTime+") ";
      prettyPrint.append(addition);
      filter += addition;
    }      
  } catch (NullPointerException npe) {
    npe.printStackTrace();
  }
  
  filter = prepForNext(filter);
  System.out.println("This filter: "+filter);
  return filter;
}
  
}
