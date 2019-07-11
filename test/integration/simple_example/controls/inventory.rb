control 'inventory' do
    describe "Inventory create is automated" do
        subject do 
            command("forseti inventory list")
        end
        before do 
            command("forseti inventory create").result
        end
        its("exit_status") { should eq 0 }
        its("stdout") { should match /PARTIAL_SUCCESS/}
        its("stderr") { should eq ""}
        after do 
            command("forseti inventory purge 0").result
        end     
    end    
end