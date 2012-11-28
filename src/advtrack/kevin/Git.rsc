module advtrack::kevin::Git

import resource::versions::Versions;
import resource::versions::git::Git;

import List;

import advtrack::LOC::FileLOC;

import IO;

public list[loc files] getFilesFromCheckoutUnit(CheckoutUnit unit, Repository repository) {
	checkoutResources(unit, repository);
		
	// Get all resources (e.g. files and folders, see resource.versions.Versions.rsc):
	wcRes = getResources(repository);
	// And create Resources of it:		
	set[Resource resource] res = {r.resource | r <- wcRes};
	
	// Return a list of the id's (locs) of the current CU
	return [r.id | r <- res];
}