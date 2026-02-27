<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
  ~
  ~    Copyright (c) 2018-2021 Green Button Alliance, Inc.
  ~
  ~    Portions (c) 2013-2018 EnergyOS.org
  ~
  ~     Licensed under the Apache License, Version 2.0 (the "License");
  ~     you may not use this file except in compliance with the License.
  ~     You may obtain a copy of the License at
  ~
  ~         http://www.apache.org/licenses/LICENSE-2.0
  ~
  ~     Unless required by applicable law or agreed to in writing, software
  ~     distributed under the License is distributed on an "AS IS" BASIS,
  ~     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  ~     See the License for the specific language governing permissions and
  ~     limitations under the License.
  ~
--%>

<!DOCTYPE html>
<html lang="en">

<jsp:include page="../../tiles/head.jsp"/>

<body>

<jsp:include page="../../tiles/customer/header.jsp"/>

<div style="margin-left: 40px;">
  <table>
    <tr>
      <td>
        <a id="downloadMyData" class="brand"
           href="<c:url value='/RetailCustomer/${currentCustomer.id}/DownloadMyData/UsagePoint/${displayBag.usagePointId}'/>">
          <img src="<c:url value='/resources/img/Green_Download_265.png'/>" width="150"/>
        </a>
      </td>
      <td>
        Start Date/Time:<br/>
        <div id="datetimepicker" class="input-append date">
          Start: <input id="startTime" type="text"/>
          <span class="add-on">
            <i data-time-icon="icon-time" data-date-icon="icon-calendar"></i>
          </span>
        </div>
      </td>
      <td>
        End Date/Time:<br/>
        <div id="datetimepicker1" class="input-append date">
          End: <input id="endTime" type="text"/>
          <span class="add-on">
            <i data-time-icon="icon-time" data-date-icon="icon-calendar"></i>
          </span>
        </div>
      </td>
    </tr>
  </table>
</div>

<script type="text/javascript"
        src="<c:url value='/resources/bootstrap-datetimepicker-0.0.11/js/bootstrap-datetimepicker.min.js'/>">
</script>

<script type="text/javascript">
  $('#datetimepicker').datetimepicker({
    format: 'yyyy-MM-dd Thh:mm:ss Z',
    language: 'pt-US',
    showMeridian: true,
    autohide: true,
    pickerPosition: "bottom-left"
  }).on('changeDate', function(ev) {
    var href = $('#downloadMyData').attr('href'),
        sep = href.indexOf('?') !== -1 ? '&' : '?',
        iso = ev.date.toISOString();
    $('#downloadMyData').attr('href', href + sep + 'published-min=' + iso);
  });

  $('#datetimepicker1').datetimepicker({
    format: 'yyyy-MM-dd Thh:mm:ss Z',
    language: 'pt-US',
    autoclose: true,
    showMeridian: true,
    pickerPosition: "bottom-left"
  }).on('changeDate', function(ev) {
    var href = $('#downloadMyData').attr('href'),
        sep = href.indexOf('?') !== -1 ? '&' : '?',
        iso = ev.date.toISOString();
    $('#downloadMyData').attr('href', href + sep + 'published-max=' + iso);
  });
</script>

<hr size="4"/>

<div class="container">
  <div class="row">
    <div class="span12">
      <h2>Usage Point: ${displayBag.Description}</h2>
      <p>Service Category: ${displayBag.ServiceCategory}</p>

      <table class="table table-striped">
        <caption class="text-left">Meter Readings:</caption>
        <thead>
          <tr>
            <th>Description</th>
            <th>Reading Type</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="mr" items="${displayBag.MeterReadings}">
            <tr>
              <td>
                <a href="${mr.Uri}">
                  <c:out value="${mr.Description}"/>
                </a>
              </td>
              <td><c:out value="${mr.ReadingType}"/></td>
            </tr>
          </c:forEach>
        </tbody>
      </table>

      <table class="table table-striped">
        <caption class="text-left">Electric Power Usage Summaries:</caption>
        <thead>
          <tr>
            <th>Description</th>
            <th>Billing Period Start</th>
            <th>Billing Period Duration</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="ups" items="${displayBag.UsageSummaryList}">
            <tr>
              <td><c:out value="${ups.description}"/></td>
              <td><c:out value="${ups.billingPeriod.start}"/></td>
              <td><c:out value="${ups.billingPeriod.duration}"/></td>
            </tr>
          </c:forEach>
        </tbody>
      </table>

      <table class="table table-striped">
        <caption class="text-left">Electric Power Quality Summaries:</caption>
        <thead>
          <tr>
            <th>Description</th>
            <th>Summary Interval Start</th>
            <th>Summary Interval Duration</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="epqs" items="${displayBag.QualitySummaryList}">
            <tr>
              <td><c:out value="${epqs.description}"/></td>
              <td><c:out value="${epqs.summaryInterval.start}"/></td>
              <td><c:out value="${epqs.summaryInterval.duration}"/></td>
            </tr>
          </c:forEach>
        </tbody>
      </table>

      <table class="table table-striped">
        <caption class="text-left">Local Time Parameters:</caption>
        <thead>
          <tr>
            <th>UTC Offset</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><c:out value="${displayBag.localTimeParameters.tzOffset}"/></td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>

  <hr>

  <jsp:include page="../../tiles/footer.jsp"/>

</div>

</body>
</html>
