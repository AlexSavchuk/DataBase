({
    doSubmit: function(component, event, helper) {
        var firstNam = component.get("v.firstName");
        var lastNam = component.get("v.lastName");
        var fullName = firstNam + ', ' + lastNam;

        component.set("v.result", fullName);

    }
})