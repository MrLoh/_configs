function divio-managepy --description 'alias for docker-compose run --rm web python manage.py'
	docker-compose run --rm web python manage.py $argv
end
