defmodule Changelog.Admin.PersonControllerTest do
  use Changelog.ConnCase
  alias Changelog.Person

  @valid_attrs %{name: "Joe Blow", email: "joe@blow.com", handle: "joeblow"}
  @invalid_attrs %{name: "", email: "noname@nope.com"}

  defp person_count(query), do: Repo.one(from p in query, select: count(p.id))

  @tag :as_admin
  test "lists all people on index", %{conn: conn} do
    p1 = insert_person()
    p2 = insert_person()

    conn = get conn, admin_person_path(conn, :index)

    assert html_response(conn, 200) =~ ~r/People/
    assert String.contains?(conn.resp_body, p1.name)
    assert String.contains?(conn.resp_body, p2.name)
  end

  @tag :as_admin
  test "renders form to create new person", %{conn: conn} do
    conn = get conn, admin_person_path(conn, :new)
    assert html_response(conn, 200) =~ ~r/new/
  end

  @tag :as_admin
  test "creates person and redirects", %{conn: conn} do
    conn = post conn, admin_person_path(conn, :create), person: @valid_attrs

    assert redirected_to(conn) == admin_person_path(conn, :index)
    assert person_count(Person) == 1
  end

  @tag :as_admin
  test "does not create with invalid attributes", %{conn: conn} do
    count_before = person_count(Person)
    conn = post conn, admin_person_path(conn, :create), person: @invalid_attrs

    assert html_response(conn, 200) =~ ~r/error/
    assert person_count(Person) == count_before
  end

  @tag :as_admin
  test "renders form to edit person", %{conn: conn} do
    person = insert_person()

    conn = get conn, admin_person_path(conn, :edit, person)
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_admin
  test "updates person and redirects", %{conn: conn} do
    person = insert_person()

    conn = put conn, admin_person_path(conn, :update, person.id), person: @valid_attrs

    assert redirected_to(conn) == admin_person_path(conn, :index)
    assert person_count(Person) == 1
  end

  @tag :as_admin
  test "does not update with invalid attributes", %{conn: conn} do
    person = insert_person()
    count_before = person_count(Person)

    conn = put conn, admin_person_path(conn, :update, person.id), person: @invalid_attrs

    assert html_response(conn, 200) =~ ~r/error/
    assert person_count(Person) == count_before
  end

  @tag :as_admin
  test "deletes a person and redirects", %{conn: conn} do
    person = insert_person()

    conn = delete conn, admin_person_path(conn, :delete, person.id)

    assert redirected_to(conn) == admin_person_path(conn, :index)
    assert person_count(Person) == 0
  end

  test "requires user auth on all actions" do
    Enum.each([
      get(conn, admin_person_path(conn, :index)),
      get(conn, admin_person_path(conn, :new)),
      post(conn, admin_person_path(conn, :create), person: @valid_attrs),
      get(conn, admin_person_path(conn, :edit, "123")),
      put(conn, admin_person_path(conn, :update, "123"), person: @valid_attrs),
      delete(conn, admin_person_path(conn, :delete, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end