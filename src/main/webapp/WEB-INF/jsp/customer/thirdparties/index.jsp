<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%--
  Copyright (c) 2018-2021 Green Button Alliance, Inc.
  Portions (c) 2013-2018 EnergyOS.org
  Licensed under the Apache License, Version 2.0
--%>
<!DOCTYPE html>
<html lang="en">

<jsp:include page="/WEB-INF/jsp/tiles/head.jsp"/>

<body>

<jsp:include page="/WEB-INF/jsp/tiles/custodian/header.jsp"/>

<div class="container">
  <div class="row">
    <div class="span12">
      <h2>Available Third-Party Applications</h2>

      <form:form method="post"
                 action="${pageContext.request.contextPath}/RetailCustomer/${retailCustomerId}/ThirdPartyList"
                 class="form-horizontal">
        <table class="table table-striped">
          <thead>
            <tr>
              <th></th>
              <th>Application</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="app" items="${applicationInformationList}">
              <tr>
                <td>
                  <input type="radio"
                         name="ThirdPartyID"
                         value="${app.clientId}"
                         onclick="document.getElementById('connectBtn').disabled=false"/>
                </td>
                <td>
                  <c:out value="${app.thirdPartyApplicationName}"/>
                </td>
              </tr>
            </c:forEach>
            <c:if test="${empty applicationInformationList}">
              <tr>
                <td colspan="2">No third-party applications available.</td>
              </tr>
            </c:if>
          </tbody>
        </table>

        <div class="form-actions">
          <button id="connectBtn"
                  type="submit"
                  class="btn btn-primary"
                  disabled>
            Connect My Data
          </button>
        </div>
      </form:form>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/jsp/tiles/footer.jsp"/>

</body>
</html>
