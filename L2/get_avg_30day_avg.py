import pandas as pd

file_path = 'l2component_last_30_days.csv'
df = pd.read_csv(file_path)

df_filtered = df[df['total_coverage'] > 0]

avg_coverage_rounded = df_filtered.groupby('component_name')['total_coverage'].mean().round().reset_index()

avg_coverage_rounded.columns = ['Component Name', 'Average Total Coverage']

output_file_path = 'avg.csv'
avg_coverage_rounded.to_csv(output_file_path, index=False)

print(f"The average total coverage data has been saved to {output_file_path}")

