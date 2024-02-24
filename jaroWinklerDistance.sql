create or replace function jaroWinklerDistance /* on cluster cluster_name */
    as (string1, string2) ->
    if(
        isNull(string1) or isNull(string2), 0,
        (
            select
                jaro_winkler_value
            from (
                select
                    string1,
                    string2,

                    cast(
                        floor(least(lengthUTF8(string1), lengthUTF8(string2)) / 2), 'UInt16'
                    )                                                                       as limit,

                    arrayStringConcat(
                        arrayMap(
                            x ->
                                (
                                    if(
                                        positionUTF8(
                                            substringUTF8(
                                                string2,
                                                greatest(1, x + 1 - limit),
                                                least(x + 1 + limit, limit * 2 + 1)

                                            ),
                                            substringUTF8(
                                                string1,
                                                x + 1,
                                                1
                                            )
                                        ) > 0,
                                        ' ',
                                        substringUTF8(
                                            string2,
                                            x + 1,
                                            1
                                        )
                                    )
                                ),
                            range(lengthUTF8(string1))
                        )
                    )                                                                       as string2_cut,

                    arrayStringConcat(
                        arrayMap(
                            x ->
                                (
                                    if(
                                        positionUTF8(
                                            substringUTF8(
                                                string1,
                                                greatest(1, x + 1 - limit),
                                                least(x + 1 + limit, limit * 2 + 1)
                                            ),
                                            substringUTF8(
                                                string2,
                                                x + 1,
                                                1
                                            )
                                        ) > 0,
                                        ' ',
                                        substringUTF8(
                                            string1,
                                            x + 1,
                                            1
                                        )
                                    )
                                ),
                            range(lengthUTF8(string2))
                        )
                    )                                                                       as string1_cut,

                    arrayMap(
                        x ->
                            substringUTF8(
                                string2_cut,
                                1,
                                x
                            ) ||
                            substringUTF8(
                                string2,
                                x + 1,
                                100
                            ),
                        range(lengthUTF8(string1))
                    )                                                                       as string2_cuts,

                    arrayMap(
                        x ->
                            substringUTF8(
                                string1_cut,
                                1,
                                x
                            ) ||
                            substringUTF8(
                                string1,
                                x + 1,
                                100
                            ),
                        range(lengthUTF8(string2))
                    )                                                                       as string1_cuts,

                    arrayStringConcat(
                        arrayMap(
                            x ->
                            if(
                                positionUTF8(
                                    substringUTF8(
                                        string2_cuts[x+1],
                                        greatest(1, x + 1 - limit),
                                        least(x + 1 + limit, limit * 2 + 1)
                                    ),
                                    substringUTF8(
                                        string1,
                                        x + 1,
                                        1
                                    )
                                ) > 0,
                                substringUTF8(
                                    string1,
                                    x + 1,
                                    1
                                ),
                                ''
                            ),
                            range(lengthUTF8(string1))
                        )
                    )                                                                       as matching_1,

                    arrayStringConcat(
                        arrayMap(
                            x ->
                            if(
                                positionUTF8(
                                    substringUTF8(
                                        string1_cuts[x+1],
                                        greatest(1, x + 1 - limit),
                                        least(x + 1 + limit, limit * 2 + 1)
                                    ),
                                    substringUTF8(
                                        string2,
                                        x + 1,
                                        1
                                    )
                                ) > 0,
                                substringUTF8(
                                    string2,
                                    x + 1,
                                    1
                                ),
                                ''
                            ),
                            range(lengthUTF8(string2))
                        )
                    )                                                                       as matching_2,

                    lengthUTF8(matching_1)                                                  as match_count,

                    toUInt16(
                        floor(
                            length(
                                arrayFilter(
                                    x ->
                                        substringUTF8(
                                            matching_1,
                                            x + 1,
                                            1
                                        ) !=
                                        substringUTF8(
                                            matching_2,
                                            x + 1,
                                            1
                                        ),
                                    range(
                                        least(
                                            lengthUTF8(matching_1),
                                            lengthUTF8(matching_2)
                                        )
                                    )
                                )
                            ) / 2
                        )
                    )                                                                       as transpositions,

                    if(
                        match_count=0,
                        0.0,
                        1 / 3
                        * (
                            match_count / lengthUTF8(string1)
                            + match_count / lengthUTF8(string2)
                            + (match_count - transpositions) / match_count
                        )
                    )                                                                       as jaro,

                    if(
                        (
                            indexOf(
                                arrayMap(
                                    x ->
                                        if(
                                            substringUTF8(
                                                string1,
                                                x + 1,
                                                1
                                            ) =
                                            substringUTF8(
                                                string2,
                                                x + 1,
                                                1
                                            ),
                                            1,
                                            0
                                        ),
                                    range(
                                        toInt16(least(lengthUTF8(string1), lengthUTF8(string2), 4)
                                    ) as prefix_chars_cnt)) as prefix_len_tmp,
                                0
                            ) - 1 as prefix_len_tmp2
                        ) = -1, prefix_chars_cnt, prefix_len_tmp2
                    )                                                                       as prefix_len,

                toFloat32(floor((jaro + 0.1 * prefix_len * (1 - jaro)) * 1000) / 1000)      as jaro_winkler_value
            )
        )
    );
