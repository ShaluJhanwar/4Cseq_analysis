#When: 20191208
#Who: Shalu Jhanwar
#What: Get top interactions, substraction map and log2ratio

#####
#Run it like this
#####
# !python get_top_interactions_2.py codes f1d1023 F1d1023 Grem1

import numpy as np
import pandas as pd
from pandas.util.testing import assert_frame_equal
import glob
import os
import argparse

parser = argparse.ArgumentParser(description='Input for the files')
parser.add_argument('data_dir', type=str)
parser.add_argument('sample_prefix', type=str)
parser.add_argument('mut_prefix', type=str)
parser.add_argument('wt_prefix', type=str)

args = parser.parse_args()
data_dir = args.data_dir
sample_prefix = args.sample_prefix
mut_prefix = args.mut_prefix
wt_prefix = args.wt_prefix

print("data dir: ", data_dir)
print("sample prefix: ", sample_prefix)
print("mutant prefix: ", mut_prefix)
print("wt prefix: ", wt_prefix)


# In[3]:


# data_dir = "."
# sample_prefix = "f1d1023"
# mut_prefix = "F1d1023"
# wt_prefix = "Grem1"

mutFile =  glob.glob(os.path.join(data_dir, sample_prefix+"_"+mut_prefix+"*"))[0]
print("mutFile: ", mutFile)
wtFile = glob.glob(os.path.join(data_dir, sample_prefix+"_"+wt_prefix+"*"))[0]
print("wtFile: ", wtFile)


# In[4]:


#comput log2 ratio
mut_normCounts_df = pd.read_csv(mutFile, sep='\t', header=None)
mut_normCounts_df.columns = ["chr", "start", "end", "normCounts"]
wt_normCounts_df = pd.read_csv(wtFile, sep='\t', header=None)
wt_normCounts_df.columns = ["chr", "start", "end", "normCounts"]


# In[25]:


#Read bait fragment
bait_chr = "chr2"
bait_start = 113757684
bait_end = 113759174


# In[6]:


assert_frame_equal(mut_normCounts_df.iloc[:, [0, 1, 2]], wt_normCounts_df.iloc[:, [0 ,1 ,2]])


# In[7]:


print("computing substraction")
mut_normCounts_df["substract_MutvsWt"] = np.round(mut_normCounts_df.iloc[:, 3] - wt_normCounts_df.iloc[:, 3], 5)
print("computing substraction finished")

print("computing log2 ratio")
mut_normCounts_df["log2Ratio_MutvsWt"] = np.round(np.log2((mut_normCounts_df.iloc[:,3] + 1e-10) / (wt_normCounts_df.iloc[:, 3] + 1e-10)), 5)
print("computing log2 ratio finished")


# In[8]:


print("Saving data")
substract_bed = mut_normCounts_df.loc[:, ["chr", "start", "end", "substract_MutvsWt"]].copy(deep=True)
substract_bed.to_csv(os.path.join(data_dir, "substract_{}vs{}.bdg".format(mut_prefix, wt_prefix)),
                     sep="\t", header=False, index=False)

log2Ratio_bed = mut_normCounts_df.loc[:, ["chr", "start", "end", "log2Ratio_MutvsWt"]].copy(deep=True)
log2Ratio_bed.to_csv(os.path.join(data_dir, "log2ratio_{}vs{}.bdg".format(mut_prefix, wt_prefix)),
                     sep="\t", header=False, index=False)


# In[9]:


# log2Ratio_bed_chr2 = log2Ratio_bed.loc[(log2Ratio_bed.loc[:, "chr"] == "chr2") & (log2Ratio_bed.loc[:, "start"] >= 113326224) & (
#     log2Ratio_bed.loc[:, "end"] <= 113894862), :].copy(deep=True).reset_index(drop=True)

# print(log2Ratio_bed_chr2.shape)

# total_lines = log2Ratio_bed_chr2.shape[0]
# print("total_lines: ", total_lines)

# log2Ratio_bed_chr2.loc[:, "log2Ratio_MutvsWt_abs"] = log2Ratio_bed_chr2.loc[:, "log2Ratio_MutvsWt"].abs()
# log2Ratio_bed_chr2.sort_values('log2Ratio_MutvsWt_abs', ascending=False, inplace=True)
# log2Ratio_bed_chr2_top_10 = log2Ratio_bed_chr2.iloc[0:int(total_lines*0.1), :].copy(deep=True)
# print("log2Ratio_bed_chr2_top_10: ", log2Ratio_bed_chr2_top_10.shape[0])


# In[12]:


substract_bed_chr2 = substract_bed.loc[(substract_bed.loc[:, "chr"] == "chr2") & (substract_bed.loc[:, "start"] >= 113326224) & (
    substract_bed.loc[:, "end"] <= 113894862), :].copy(deep=True).reset_index(drop=True)

print(substract_bed_chr2.shape)
substract_bed_chr2.head()


# In[64]:


substract_bed_chr2.loc[substract_bed_chr2.loc[:, "start"] == 113766397, :]


# In[18]:


total_lines = substract_bed_chr2.shape[0]
print("total_lines: ", total_lines)

substract_bed_chr2.loc[:, "substract_MutvsWt_abs"] = substract_bed_chr2.loc[:, "substract_MutvsWt"].abs()
substract_bed_chr2.sort_values('substract_MutvsWt_abs', ascending=False, inplace=True)

for i in [0.2, 0.1, 0.05]:
    substract_bed_chr2_top_10 = substract_bed_chr2.iloc[0:int(total_lines*i), :].copy(deep=True)
    print("substract_bed_chr2_top_{}:".format(int(i*100)), substract_bed_chr2_top_10.shape[0])

    interact_df = pd.DataFrame({"chrom": [], "chromStart": [], "chromEnd": [], "name": [], "score": [],
                            "value": [], "exp": [], "color": [],
                            "sourceChrom": [], "sourceStart": [], "sourceEnd": [], "sourceName": [], "sourceStrand": [],
                            "targetChrom": [], "targetStart": [], "targetEnd": [], "targetName": [], "targetStrand": []})
#     interact_df[["chrom", "chromStart", "chromEnd"]] = substract_bed_chr2_top_10.loc[:, ["chr", "start", "end"]].copy(deep=True)
    interact_df["chrom"] = substract_bed_chr2_top_10.loc[:, "chr"].copy(deep=True)
    interact_df["chromStart"] = substract_bed_chr2_top_10.loc[:, "start"].copy(deep=True)
    interact_df["chromEnd"] = substract_bed_chr2_top_10.loc[:, "end"].copy(deep=True)
    interact_df[["name", "exp", "sourceName", "sourceStrand", "targetName", "targetStrand"]] = "."
#     interact_df[["targetChrom", "targetStart", "targetEnd"]] = substract_bed_chr2_top_10.loc[:, ["chr", "start", "end"]].copy()
    interact_df["targetChrom"] = substract_bed_chr2_top_10.loc[:, "chr"].copy(deep=True)
    interact_df["targetStart"] = substract_bed_chr2_top_10.loc[:, "start"].copy(deep=True)
    interact_df["targetEnd"] = substract_bed_chr2_top_10.loc[:, "end"].copy(deep=True)
    interact_df.loc[:, "sourceChrom"] = bait_chr
    interact_df.loc[:, "sourceStart"] = bait_start
    interact_df.loc[:, "sourceEnd"] = bait_end
    interact_df["value"] = 5
    interact_df["score"] = 0
    interact_df["color"] = substract_bed_chr2_top_10.loc[:, "substract_MutvsWt"].apply(lambda x: "#C23856" if x > 0 else "#389BC2")

    ##RGB #c23856 = 194, 56, 86
    ##RGB "#389bc2" = 56, 155, 194

    interact_df.to_csv(os.path.join(data_dir, "interaction_top{:02d}_{}vs{}.bdg".format(int(i*100), mut_prefix, wt_prefix)),
                       sep="\t", header=False, index=False)

    name = "interaction_top{:02d}_{}vs{}".format(int(i*100), mut_prefix, wt_prefix)
    header_1 = "track type=interact name=\"{}\" description=\"{}\" interactUp=true maxHeightPixels=200:100:50 visibility=full".format(name, name)
    header_2 = "browser position chr2:113326224-113894862"

    with open(os.path.join(data_dir, "interaction_top{:02d}_{}vs{}.bdg".format(int(i*100), mut_prefix, wt_prefix)), "r+") as fd:
        content = fd.read()
        fd.seek(0, 0)
        fd.write(header_1.rstrip('\r\n') + '\n' + header_2.rstrip('\r\n') + '\n' + content)

    del substract_bed_chr2_top_10
    del interact_df




