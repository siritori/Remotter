all:
	erlc -o ebin src/*.erl
run:
	erl -boot start_sasl -pa ebin -config ebin/remotter_error
clean:
	$(RM) ebin/*.beam

