component extends="mxunit.framework.TestCase"{
	
	include "configs.cfm";
	variables.dsn = "railoserviceapi";
	
	
	public void function setUp(){
	}

	public void function tearDown(){
	}

	public void function simple_creation_must_return_a_cfc_query_object(){
		var q = getObject('query');
		assertTrue(isObject(q),"new query does not return an object");	
	
	}
	
	public void function simple_execute_return_query_recordset(){
		var sql = 'select * from team';
		var q = getObject('query',{datasource = variables.dsn, sql = sql});
		var result = q.execute();	
		assertTrue(isvalid("Query",result.getResult()),"result is not a valid query");
		assertTrue(trim(result.getPrefix().sql) == sql,"Error in prefix");	
	
	}
	
	
	public void function test_getNamedParams(){
		var q = getObject('query');
		makePublic(q,'getNamedParams');
		q.addParam(name="p1",value="1",cfsqltype="cf_sql_varchar");
		q.addParam(name="p2",value="2",cfsqltype="cf_sql_varchar");
		q.addParam(value="3",cfsqltype="cf_sql_varchar");		
		var result = q.getNamedParams();
		assertTrue(result.size() == 2);
		assertTrue(result[1].name == 'p1');
		
	}

	public void function test_getPositionalParams(){
		var q = getObject('query');
		makePublic(q,'getPositionalParams');
		q.addParam(name="p1",value="1",cfsqltype="cf_sql_varchar");
		q.addParam(name="p2",value="2",cfsqltype="cf_sql_varchar");
		q.addParam(value="3",cfsqltype="cf_sql_varchar");		
		var result = q.getPositionalParams();
		assertTrue(result.size() == 1);
		assertTrue(result[1].value == 3);
		
	}
	
	public void function test_parse_sql(){
		var q = getObject('query');
		makePublic(q,'parseSql');

		q.addParam(name="wrong",value="1",cfsqltype="cf_sql_numeric");
		q.addParam(name="myid",value="1",cfsqltype="cf_sql_numeric");
		q.addParam(value="hello",cfsqltype="cf_sql_varchar");		
		
		var sql = "Select from table where id = :myid and name = ?";
		q.setSql(sql);
		var result = q.parseSql();
		assertTrue(arrayLen(result) eq 4);
		assertTrue(trim(result[1].value) eq  'Select from table where id =');
		assertTrue(trim(result[2].name) eq 'myid');
		
	}

	public void function test_findNamedParam(){
		var q = getObject('query');
		makePublic(q,'findNamedParam');

		var params = [
			{value="value",cfsqltype="cf_sql_varchar"},
			{name="param1",value="10",cfsqltype="cf_sql_numeric"},
			{name="param2",value="20",cfsqltype="cf_sql_numeric"}
		]
		
		var res = q.findNamedParam(params,'param1');
		assertTrue(res.value eq 10);
		
		var res = q.findNamedParam(params,'param2');
		assertTrue(res.value eq 20);
		
	}

	public void function test_findNamedParam_not_found_exception() 
		mxunit:expectedException="org.railo.cfml.query.namedParameterNotFoundException"
		{
		var q = getObject('query');
		makePublic(q,'findNamedParam');

		var params = [
			{value="value",cfsqltype="cf_sql_varchar"},
			{name="param1",value="10",cfsqltype="cf_sql_numeric"},
			{name="param2",value="20",cfsqltype="cf_sql_numeric"}
		]
		
		var res = q.findNamedParam(params,'not_exists');
		
	}
	
	public void function test_execute(){
		
		var q = getObject('query',{datasource=variables.dsn});
		q.addParam(name="domain",value="com",cfsqltype="cf_sql_varchar");
		q.addParam(value="gert",cfsqltype="cf_sql_varchar");				
		var sql = "Select * from team where dom = :domain and firstname = ?";
		q.setSql(sql);
		
		var qres = q.execute();
		
		var result = qres.getResult();
		var prefix = qres.getPrefix();
		
		assertTrue(result.recordcount eq 1);
		assertTrue(result.lastname eq 'frantz');
		
	}
	
	public void function test_clear_params(){
		
		var q = getObject('query',{datasource=variables.dsn});
		q.addParam(name="domain",value="com",cfsqltype="cf_sql_varchar");
		q.addParam(value="gert",cfsqltype="cf_sql_varchar");	
		var sql = "Select * from team where dom = :domain and firstname = ?";
		q.setSql(sql);
		
		var qres = q.execute();		
		var result = qres.getResult();
		
		assertTrue(result.recordcount eq 1);
		assertTrue(result.lastname eq 'frantz');

		q.clearParams();
		
		assertTrue(arrayIsEmpty(q.getParams()));		
		
		// change just the params while sql is still the same
		q.addParam(name="domain",value="org",cfsqltype="cf_sql_varchar");
		q.addParam(value="todd",cfsqltype="cf_sql_varchar");	
		
		qres = q.execute();		
		result = qres.getResult();
		
		assertTrue(result.recordcount eq 1);
		assertTrue(result.lastname eq 'rafferty');
		
	}


}
