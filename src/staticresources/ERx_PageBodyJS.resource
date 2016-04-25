var mainApp = angular.module("mainApp", []);  
mainApp.controller('mainAppController', function($scope, $http, $sce, DataService,$q,$timeout){
	$scope.test = 'test';
	$scope.items = [];
	$scope.modelList = {!modelsDataJSON};
	console.log($scope.modelList);
	$scope.sectionList = {!sectionJSON};
	$scope.lookupString = '';
	
	$scope.save= function() {
		DataService.saveData($scope.modelList).then(function(data) {
		});
	}
	  
	
	$scope.add= function(modelname) {
		var sampleObj = new Object() ;
		$.each($scope.modelList[modelname][0], function(key, element) {
			if(key != '$$hashKey')
				sampleObj[key] = null;
		}); 
		$(sampleObj).attr('attributes', $($scope.modelList[modelname][0]).attr('attributes'));
		$scope.modelList[modelname].push(sampleObj );
		$timeout(function () {
		   initDatePicker();
		});
	} 
	
	$scope.delete= function(modelName,index) {
		var c =  $scope.modelList[modelName].splice(index,1);   
		if( c[0] != null && c[0].Id != null){ 
		  Visualforce.remoting.Manager.invokeAction(
		'{!$RemoteAction.PageExecutorController.deleteData}',
		JSON.stringify(c[0]), 
		function(result, event){
			if (event.status) {
			   
			} else if (event.type === 'exception') {
			   
			} else {
			   
			}
		}, 
		{escape: true}
	);
		}else{
	   
		}  
	}
	
	$scope.htmlbinding = function(value) {
		return $sce.trustAsHtml(value);
	};
	
	$scope.removeSelection = function(fieldIndex, sectionIndex, fieldApiName, fieldDisplayApiName) {
		//alert(fieldIndex + ' -- ' + sectionIndex);
		$scope.modelList[$scope.sectionList[sectionIndex].modelName][fieldIndex][fieldApiName] = '';
		$scope.modelList[$scope.sectionList[sectionIndex].modelName][fieldIndex][fieldDisplayApiName].Name = '';
	}
	
	$scope.selectLookup = function(obj, fieldIndex, sectionIndex, fieldApiName, fieldDisplayApiName) {
		$scope.modelList[$scope.sectionList[sectionIndex].modelName][fieldIndex][fieldApiName] = obj.Id;
		if(typeof $scope.modelList[$scope.sectionList[sectionIndex].modelName][fieldIndex][fieldDisplayApiName] == 'undefined' ||  $scope.modelList[$scope.sectionList[sectionIndex].modelName][fieldIndex][fieldDisplayApiName] == null){
			$scope.modelList[$scope.sectionList[sectionIndex].modelName][fieldIndex][fieldDisplayApiName] = new Object();
			$scope.modelList[$scope.sectionList[sectionIndex].modelName][fieldIndex][fieldDisplayApiName].id = obj.Id; 
		}
		$scope.modelList[$scope.sectionList[sectionIndex].modelName][fieldIndex][fieldDisplayApiName].Name = obj.Name;
	}
	
	$scope.getLookupDetails = function(object, searchStringValue, fieldIndex, sectionIndex, fieldApiName, fieldDisplayApiName) {
		Visualforce.remoting.Manager.invokeAction(
			'{!$RemoteAction.PageExecutorController.getLookupDataByObjectAndName}',
			JSON.stringify(object), JSON.stringify(searchStringValue),
			function(result, event){
				if(event.statusCode == 200) {
					$timeout(function() {
						$scope.sectionList[sectionIndex].field[fieldIndex].lookupValueList  = result;
					});    
				}
			},
			{escape: true}
		);      
	}      
});

mainApp.service('DataService', function($q) {              
	this.saveData= function(a) {
	delete a.$$hashKey;
				
	var serverData = angular.toJson(a);
	var deferred = $q.defer();
	Visualforce.remoting.Manager.invokeAction(
		'{!$RemoteAction.PageExecutorController.updateData}',
		serverData , 
			function(result, event){
				if (event.status) {
					var customer = JSON.stringify(result);
					var find = '\'';
					var re = new RegExp(find, 'g');
					customer = customer.replace(re, '');
					deferred.resolve(JSON.parse(customer));
				} else if (event.type === 'exception') {
					deferred.reject(JSON.parse('[]'));
				} else {
				  
				}
			}, 
				 {escape: true}
		 );              
		 return deferred.promise;
	}
});