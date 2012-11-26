module workingexperiments::git

import resource::versions::Versions;
import resource::versions::git::Git;

import IO;

str gitLoc = "/home/kevin/src/rascal-msr/";

public void main() {
	// Create a 'Connection' datatype.
	con = fs(gitLoc);
	
	// Reverse so the oldest revision will be on top
	set[LogOption] opt = {reverse()};
	
	// Create a 'Repository' datatype of the git Connection
	repo = git(con, "", opt);
	
	// Get all changesets of this git Repository
	cs = getChangesets(repo);
	
	// Get all resources (e.g. files and folders, see resource.versions.Versions.rsc):
	wcRes = getResources(repo);
	// And create Resources of it:		
	set[Resource resource] res = {r.resource | r <- wcRes};

	// Get all CheckoutUnits of the current repo:	
	cu = getCheckoutUnits(getRevisions(cs));
	
	for(c <- cu) {
		res = checkoutResources(c, repo);
	}
}

/**
 * Create a list of revisions based on a given list of changesets.
 * @param cs A list of changesets.
 * @return list[Revision] A list of revisions.
 */
private list[Revision] getRevisions(list[ChangeSet] cs) {
	return [ x.revision | x <- cs];
}

/**
 * Create a list of CheckoutUnits based on a given list of revisions.
 * @param rev A list of revisions
 * @return list[CheckoutUnit] A list of CheckoutUnits.
 */
private list[CheckoutUnit] getCheckoutUnits(list[Revision] revs) {
	return [ cunit(r) | r <- revs];
}
