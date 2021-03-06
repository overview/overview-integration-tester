Integration Testing
===================

These tools test that Overview and plugins work the way we expect.

The code is in [Ruby](https://www.ruby-lang.org/en/). You don't need to know
much Ruby to get started.

Installation
============

* [Install Docker](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/)
* [Install vncviewer](https://www.realvnc.com/en/connect/download/viewer/) and
  make sure it's in your `$PATH`. There are many `vncviewer` variants out there,
  and any of them will work for our purposes.

You can install this into your project's git repository by running:

```bash
curl https://raw.githubusercontent.com/overview/overview-integration-tester/master/install.sh \
       | bash -s integration-test
```

This will create `integration-test/` with some files and subdirectories.

The rest of this file assumes your current working directory is the root of your
project and you installed to `integration-test/`.

Configuring
-----------

Your project is yours, not Overview's. After the installation script, your code
is completely standalone. These tools are minimal: it's up to you to configure
them fully.

* `integration-test/config`: Bash-syntax environment variables.
* `integration-test/files/*`: Files you may want to upload. Tests can access
  these from `/app/files/`.
* `integration-test/spec/*_spec.rb`: Feature specifications you create.
* `integration-test/helpers/*_helper.rb`: Extra code that is auto-included
  before tests. This is a good place to write `Module`s to extend
  `Capybara::Session`.
* `integration-test/docker-compose.yml`: full test environment, used by
  `integration-test/run-in-docker-compose`

For instance, to create a `go_to_home` method:

1. Create `integration-test/helpers/go_to_home_helper.rb`: `module GoToHomeHelper; def go_to_home; visit '/login'; end; end
2. In `integration-test/spec/my_feature_spec.rb`, include it: `def session_helpers; [ GoToHomeHelper ]; end`
3. In your test in `integration-test/spec/my_feature_spec.rb`, use it: `it 'should go to home'; page.go_to_home; page.assert_selector('h1'); end`

Running Tests
=============

Run all tests
-------------

To *run all tests in a fresh Overview environment*, run
`integration-test/run-in-docker-compose`

This is useful in a Jenkins pipeline:

```
stage('Integration test') {
  sh 'integration-test/run-in-docker-compose || true'
  junit 'integration-test/reports/**/*.xml'
}
```

Pulling, building, spinning up and shutting down all Overview's (and your)
containers makes testing slow. You can skip all that:

Run all tests when Overview's (and your) containers are up already
------------------------------------------------------------------

To *run all tests*, run `integration-test/run`. This expects some environment
variables to describe how to connect to Overview: see `integration-test/config`.

This will output to `integration-test/test-results.xml`. That's in a format
[Jenkins](https://jenkins-ci.org/) can understand.

Tests can take a long time to run, so you might want to run just _one_ test:

Run one test
------------

To *run one test*, run, for instance, `integration-test/run my_feature_spec`.

Now, how did we make a test?

Develop a test
--------------

Edit `integration-test/spec/my_feature_spec.rb`. Or rename it. Or create a new
file with the same structure. Anything in `integration-test/spec/*_spec.rb` will
work.

Make sure its first lines are:

```ruby
#!/usr/bin/env ruby

require './spec/spec_helper'
```

Make sure it's executable: `chmod +x integration-test/spec/my_feature_spec.rb`

Now write `describe`, `before`, `after` and `it` blocks to test your feature.

Tests are about clicking on things and seeing what happens. The best way to get
familiar with that is to actually click on things and see what happens.

Click on things and see what happens
------------------------------------

Tests involve clicking and typing and looking at a web browser window. But
`integration-test/run` is "headless" -- it does not render a web browser
window.

To _develop_ and _debug_ tests, you'll probably want to see a web browser
window: exactly the web browser window that the test platform uses, with exactly
the same network configuration. We show it, cross-platform, with
[VNC](https://en.wikipedia.org/wiki/Virtual_Network_Computing).

Run `integration-test/run-browser` to open a browser.

If you want to upload files in this environment, upload them from
`/app/files`. Those are the files the integration tests access.

You can _watch_ a test: `integration-test/run-browser spec/my_feature_spec.rb`

If your test is failing and Chromium is exiting too quickly for you to debug,
add `sleep` in your test code and re-run
`integration-test/run-browser my_feature_spec`. You can open Developer Tools
to see why the next line of code is about to fail.

Test Tips
---------

Most importantly: *know what to wait for*. Integration tests run far, far
faster than humans. It's a bug if your test tries to interact with an HTML
element that isn't yet loaded, that is being animated, that doesn't have event
listeners yet, or that is about to disappear. These are called "races", and
they make tests pass sometimes and fail other times. Some races you miss on
your development computer will happen on other computers.

Here's how to avoid races. Design your test as a sequence like this:

1. Do something
2. Wait for its effect(s)
3. Do something
4. Wait for its effect(s)
5. ... and so on

Always comment what you're waiting for and why it's important. Re-run tests a
few times before you commit: if your test even fails _once_, that's a critical
bug that you must fix before committing.

For instance, here is good code. It clicks, waits, and then clicks again:

```ruby
page.click_link('Open dropdown')
page.click_link('Link in the dropdown', wait: WAIT_FAST) # wait for dropdown to open
```

Use `WAIT_FAST` when waiting for JavaScript, `WAIT_LOAD` when waiting for an
HTTP response, and `WAIT_SLOW` when waiting for a giant backend process.

*Use the Docker version of Chromium*, not your own. It has a different network
configuration, and that's important.

*Be careful with iframes*. Use
[page.within_frame('...')](http://www.rubydoc.info/github/jnicklas/capybara/Capybara/Session#within_frame-instance_method).
Capybara will give an unhelpful "unable to find visible element" if you look in
the wrong iframe. (Iframes can't see one another's contents.)

Here is an example that deals with iframes:

```ruby
page.click_link('Open popup')
# wait for modal to load
page.assert_selector('#view-app-modal-dialog-iframe', wait: WAIT_LOAD)
# No "#": view-app-... is an id, not a selector
within_frame('view-app-modal-dialog-iframe') do
  # wait for iframe _contents_ to load
  page.click_link('Close popup', wait: WAIT_LOAD)
end
# wait for iframe to close
page.assert_no_selector('#view-app-modal-dialog-iframe', wait: WAIT_FAST)
```

*Beware Capybara's inconsistent selectors*. In `page.click_link(selector)`,
`selector` is text, id or title. In `page.find(selector).click`, `selector` is
CSS. Prefer the `click_link()` kind (it's more like English), but there will
always be both; don't let Capybara's confusing design confuse you.

*Documentation* is at https://github.com/teamcapybara/capybara and
http://www.rubydoc.info/github/jnicklas/capybara/Capybara/Session
and other spots online. One detail sets us apart: we do _not_ use
`Capybara.default_max_wait_time` because it is terrible.

Changelog and Update Instructions
=================================

**3.0.1**, released 2020-04-09

Changes:

* Re-included "webrick", so specs can require it.
* Re-included "xvfb-run", to fix ./run.
* Nix "curl", which is unused.

To upgrade:

* Change `OVERVIEW_INTEGRATION_TESTER_VERSION` to `3.0.1`

**3.0.0**, released 2020-04-08

Changes:

* Upgraded to Chromium 79
* Switched to alpine for even-faster pull
* Upgarded Overview

To upgrade:

* Change `OVERVIEW_INTEGRATION_TESTER_VERSION` to `3.0.0` and update
  `OVERVIEW_VERSION` to at least `a19aeed0cfcc2417a1ddc135f424ecf76748285b`
* (To follow changes in `overview-server` project): set
  `DEVELOPMENT_PROJECT_NAME=overview-server`
* Nix the `--shm-size` Docker flag from your `./run`.
* If you modified your `run` script to invoke `xvfb-run`, remove the
  `--init` Docker flag.
* Overwrite your `run` by downloading
  [run-browser @ v3.0.0](https://raw.githubusercontent.com/overview/overview-integration-tester/v3.0.0/skeleton/run-browser)
* Overwrite your `run-browser` by downloading
  [run-browser @ v3.0.0](https://raw.githubusercontent.com/overview/overview-integration-tester/v3.0.0/skeleton/run-browser)
* Overwrite your `spec/spec_helper.rb` with
  [spec/spec_helper.rb @ v3.0.0](https://raw.githubusercontent.com/overview/overview-integration-tester/v3.0.0/skeleton/spec/spec_helper.rb)

**2.0.0**, released 2018-04-10

Changes:

* Upgraded to Chromedriver 2.37 and Chromium 64
* Switched to debian-slim for faster pull
* Upgraded Overview

To upgrade:

* Change `OVERVIEW_INTEGRATION_TESTER_VERSION` to `2.0.0` and update
  `OVERVIEW_VERSION` to at least `ba89c4502319969f3bd9248150e8608c085d7c7e`
* Add `OV_APPLICATION_SECRET` environment variable to `overview-web` with
  any String value
* Add `overview-convert-pdf` instance, if your tests use any PDF imports
* Overwrite `helpers/session_helpers/document_set_helper.rb`. (It now disables
  OCR when uploading PDFs: that lets you omit `overview-convert-pdfocr` from
  `docker-compose.yml` and speed up tests.)

Releasing This Framework
========================

1. Fix a bug or add a feature, presumably by writing tests in `test/` and/or
   editing code in `skeleton/`.
2. Pick a new version number, `X.Y.Z` (consulting `VERSION` and semver).
3. `docker build docker -t overview/overview-integration-tester:X.Y.Z`
4. `./test/test.sh`
5. `./release X.Y.Z`
