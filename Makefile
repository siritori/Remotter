all:
	./rebar compile
run:
	erl -boot start_sasl -pa ebin -sname remotter@local -detached -config ebin/remotter_error -s application start remotter
clean:
	$(RM) ebin/*.beam
	$(RM) error_logs/*

