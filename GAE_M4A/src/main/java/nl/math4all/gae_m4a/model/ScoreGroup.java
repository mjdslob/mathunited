package nl.math4all.gae_m4a.model;

import java.util.ArrayList;
import java.util.List;

public class ScoreGroup {
	public String title;
	public int score;
	public int total;
	public List<ScoreGroup> groups = new ArrayList<ScoreGroup>();
	public List<Score> items = new ArrayList<Score>();
}
