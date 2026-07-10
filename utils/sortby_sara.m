function peth_sorted = sortby_sara(pethdata, sortorder, resp_idx, show_nr)
% Sort PETH rows by max/min/mean response; option: group by response type.
%
%   peth_sorted = SORTBY(pethdata, sortorder)
%   peth_sorted = SORTBY(pethdata, sortorder, resp_idx)
%   peth_sorted = SORTBY(pethdata, sortorder, resp_idx, show_nr)
%
%   Sorts the rows of a units-by-bins PETH matrix so that units with
%   similar response timing appear adjacent (for nice heatmaps).
%
%   INPUTS
%   pethdata   - [nUnits x nBins] matrix, one PETH per row
%   sortorder  - 'max'  : sort by bin of peak firing
%                'min'  : sort by bin of trough firing
%                'mean' : sort by mean firing across bins
%   resp_idx   - (optional) [nUnits x 1] response-type label per unit,
%                e.g. 1 = excited, -1 = suppressed, 0 = non-responsive.
%                If omitted, all units are sorted together by sortorder.
%                If provided, units are grouped by label first; within
%                each group, excited (1) units sort by max, suppressed
%                (-1) units sort by min, and all other labels sort by
%                sortorder.
%   show_nr    - (optional, default 0) if resp_idx is given, whether to
%                include label-0 (non-responsive) units in the output.
%
%   OUTPUT
%   peth_sorted - pethdata with rows reordered. If resp_idx is given,
%                 rows are also reordered into response-type blocks.
%
%   EXAMPLES
%   % Sort all units by time of peak firing, no grouping
%   peth_sorted = sortby(peth, 'max');
%
%   % Sort by mean firing rate, grouped into excited/suppressed/non-resp
%   peth_sorted = sortby(peth, 'mean', respIdx);
%
%   % Same as above but keep non-responsive (label 0) units in output
%   peth_sorted = sortby(peth, 'mean', respIdx, 1);

    switch lower(sortorder)
        case 'max',  [~,idx_sort] = max(pethdata, [], 2);
        case 'min',  [~,idx_sort] = min(pethdata, [], 2);
        case 'mean', idx_sort = mean(pethdata, 2);
        otherwise,   error('sortby must be ''max'', ''min'', or ''mean''');
    end

    if nargin < 3
        % No resp_idx given: just sort everything by sortorder
        [~, order]  = sort(idx_sort);
        peth_sorted = pethdata(order, :);
        return
    end

    if nargin < 4
        show_nr = 0;
    end

    peth_sorted = [];
    if ~all(isnan(resp_idx(:)))
        resptypes = sort(unique(resp_idx));
        if ~show_nr
            resptypes = resptypes(resptypes~=0);
        end
        for g = resptypes'
            group_rows = find(resp_idx == g);
            % Choose sort criterion based on response type
            if g == 1
                [~, group_idx] = max(pethdata(group_rows, :), [], 2);
            elseif g == -1
                [~, group_idx] = min(pethdata(group_rows, :), [], 2);
            else
                % g == 0 (or any other value): sort by the globally indicated value
                group_idx = idx_sort(group_rows);
            end
            [~, order]  = sort(group_idx);
            peth_sorted = [peth_sorted; pethdata(group_rows(order), :)];
        end
    else
        [~, order]  = sort(idx_sort);
        peth_sorted = pethdata(order, :);
    end
end