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
      <h2>Authorize “${applicationInformation.thirdPartyApplicationName}”</h2>
      <p>Select which scopes this application may use:</p>

      <form:form method="post"
                 action="${pageContext.request.contextPath}/RetailCustomer/${retailCustomerId}/ScopeSelection/startAuth"
                 class="form-horizontal">
        <input type="hidden" name="clientId"
               value="${applicationInformation.clientId}"/>
        <input type="hidden" name="redirectUri"
               value="${applicationInformation.redirectUri}"/>

        <c:forEach var="s" items="${availableScopes}">
          <div class="control-group">
            <div class="controls">
              <label class="checkbox">
                <input type="checkbox"
                       name="scope"
                       value="${s}"
                       checked/>
                ${s}
              </label>
            </div>
          </div>
        </c:forEach>

        <div class="form-actions" style="margin-top:1em;">
          <button type="submit" class="btn btn-success">Authorize</button>
        </div>
      </form:form>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/jsp/tiles/footer.jsp"/>

</body>
</html>
