module advtrack::kevin::GitHelper

import resource::versions::Versions;
import resource::versions::git::Git;

/**
 * Create a list of revisions based on a given list of changesets.
 * @param cs A list of changesets.
 * @return list[Revision] A list of revisions.
 */
public list[Revision] getRevisions(list[ChangeSet] cs) {
	return [ x.revision | x <- cs];
}

/**
 * Create a list of CheckoutUnits based on a given list of revisions.
 * @param rev A list of revisions
 * @return list[CheckoutUnit] A list of CheckoutUnits.
 */
public list[CheckoutUnit] getCheckoutUnits(list[Revision] revs) {
	return [ cunit(r) | r <- revs];
}
