"""Tests for the cli module."""

from unittest import TestCase, mock
from os import environ
from argparsenv import ArgumentParser


class TestArgumentParser(TestCase):
    """Tests the ArgumentParser class."""

    def test_add_argument_expects_correct_default_from_fallback_with_env_var(self):
        """Tests that the default value of an argument is set correctly"""
        env_var_key = "MY_APP_PORT"
        cli_arg_key = "--port"
        cli_arg_dest = "port"
        default_arg_value = "3306"

        k = mock.patch.dict(environ, {})

        k.start()

        env_arg_parser = ArgumentParser()
        env_arg_parser.add_argument(
            cli_arg_key,
            dest=cli_arg_dest,
            env_var=env_var_key,
            default=default_arg_value,
        )

        k.stop()

        self.assertEqual(env_arg_parser.get_default("port"), default_arg_value)

    def test_add_argument_expects_correct_default_from_fallback_without_env_var(self):
        """Tests that the default value of an argument is set correctly"""
        cli_arg_key = "--port"
        cli_arg_dest = "port"
        default_arg_value = "3306"

        k = mock.patch.dict(environ, {})

        k.start()

        env_arg_parser = ArgumentParser()
        env_arg_parser.add_argument(
            cli_arg_key,
            dest=cli_arg_dest,
            default=default_arg_value,
        )

        k.stop()

        self.assertEqual(env_arg_parser.get_default("port"), default_arg_value)

    def test_add_argument_expects_correct_default_from_environment(self):
        """Tests that the default value of an argument is set from the environment"""
        env_var_key = "MY_APP_DB_PORT"
        env_var_value = "3307"
        cli_arg_key = "--port"
        cli_arg_dest = "port"
        default_arg_value = "3306"

        k = mock.patch.dict(environ, {env_var_key: env_var_value})

        k.start()

        env_arg_parser = ArgumentParser()
        env_arg_parser.add_argument(
            cli_arg_key,
            dest=cli_arg_dest,
            env_var=env_var_key,
            default=default_arg_value,
        )

        k.stop()

        self.assertEqual(env_arg_parser.get_default("port"), env_var_value)

    def test_add_argument_expects_correct_default_from_environment_with_spaces(self):
        """Tests that the default value of an argument is set from the environment"""
        env_var_key = "MY_APP_DB_PORT"
        env_var_value = "3307"
        cli_arg_key = "--port"
        cli_arg_dest = "port"
        default_arg_value = "3306"

        k = mock.patch.dict(environ, {env_var_key: env_var_value})

        k.start()

        env_arg_parser = ArgumentParser()
        env_arg_parser.add_argument(
            cli_arg_key,
            dest=cli_arg_dest,
            env_var=" " + env_var_key + " ",
            default=default_arg_value,
        )

        k.stop()

        self.assertEqual(env_arg_parser.get_default("port"), env_var_value)

    def test_get_value_from_environment(self):
        """Tests that the _get_value_from_environment method works as expected."""
        env_var_key = "MY_APP_DB_PORT"
        env_var_value = "3307"
        fallback_value = "foo"

        k = mock.patch.dict(environ, {env_var_key: env_var_value})

        k.start()

        env_arg_parser = ArgumentParser()

        self.assertEqual(
            env_arg_parser.get_value_from_environment(
                env_key=env_var_key, fallback_value=None
            ),
            env_var_value,
        )
        self.assertEqual(
            env_arg_parser.get_value_from_environment(
                env_key=" " + env_var_key + " ", fallback_value=None
            ),
            env_var_value,
        )
        self.assertEqual(
            env_arg_parser.get_value_from_environment(
                env_key=None, fallback_value=None
            ),
            None,
        )
        self.assertEqual(
            env_arg_parser.get_value_from_environment(
                env_key=None, fallback_value=fallback_value
            ),
            fallback_value,
        )
        self.assertEqual(
            env_arg_parser.get_value_from_environment(
                env_key="NOTHINGREAL", fallback_value=fallback_value
            ),
            fallback_value,
        )

        k.stop()
