require 'pathname'

module SessionHelpers
  module DocumentSetHelper
    def create_document_set_from_pdfs_in_folder(folder)
      folder = Pathname.new(folder).expand_path # absolute path

      visit('/')
      click_on('Upload files', wait: WAIT_LOAD)
      assert_selector('.upload-folder-prompt', wait: WAIT_LOAD)
      execute_script('document.querySelector(".upload-prompt .invisible-file-input").style.opacity = 1')
      for path in Dir.glob(File.join(folder, '*.*'))
        attach_file('file', path)
      end
      click_on('Done adding files')
      # Wait for focus: that's when the dialog is open
      wait_for_javascript_to_return_true('document.querySelector("#import-options-name") === document.activeElement', wait: WAIT_FAST)
      fill_in('Document set name', with: folder)
      click_on('Import documents')
      assert_selector('body.document-set-show', wait: WAIT_SLOW) # wait for import to complete
      assert_selector('#document-list:not(.loading) li.document', wait: WAIT_LOAD) # wait for document list to load
      # There are no plugins, so we don't need to wait for them

      # Hide the Tour
      click_link('Don’t show any more tips', wait: WAIT_FAST)
      assert_no_selector('.popover', wait: WAIT_FAST)
    end

    def create_custom_view(options)
      raise ArgumentError.new('missing options[:name]') if !options[:name]
      raise ArgumentError.new('missing options[:url]') if !options[:url]
      click_on('Add view', wait: WAIT_FAST)
      click_on('Custom…', wait: WAIT_FAST)
      # Wait for focus: that's when the dialog is open
      wait_for_javascript_to_return_true('document.querySelector("#new-view-dialog-title") === document.activeElement', wait: WAIT_FAST)
      # Fill in App URL and _then_ Name. That's because Overview has a bit of an
      # key URL-checking feature that only checks on blur. Filling in the name
      # _second_ means we trigger the blur.
      fill_in('App URL', with: options[:url])
      fill_in('Name', with: options[:name])
      click_on('use it anyway') if options[:url] =~ /^http:/ # dismiss HTTPS warning
      assert_selector('#new-view-dialog div.ok', text: 'This URL is valid', visible: true, wait: WAIT_LOAD)
      click_on('Create visualization')
      # The test should wait for the plugin to load. We won't do that, because
      # we don't know whether the plugin will create a modal dialog. (If it does,
      # we won't be able to check for elements appearing underneath it.)
    end

    def delete_current_view
      n_views_before = all('ul.view-tabs>li.view').count
      find('li.view.active .toggle-popover').click
      within('li.view.active .popover', wait: WAIT_FAST) do
        accept_confirm(wait: WAIT_FAST) do
          click_on('Delete')
        end
      end
      # Wait for the view to disappear
      assert_selector('ul.view-tabs>li.view', count: n_views_before - 1, wait: WAIT_LOAD)
    end
  end
end
