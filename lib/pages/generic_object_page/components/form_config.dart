const formConfig = {
  "type": "column",
  "children": [
    {
      "type": "field",
      "label": "Valore Numerico",
      "controllerKey": "numericValueController",
      "fieldType": "number",
      "filter": {"enabled": true, "type": "range"}
    },
    {
      "type": "field",
      "label": "Data Creazione",
      "controllerKey": "creationDateController",
      "fieldType": "date",
      "filter": {"enabled": true, "type": "dateRange"}
    }
  ]
};
