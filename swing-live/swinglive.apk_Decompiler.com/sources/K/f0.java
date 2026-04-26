package k;

import android.app.SearchableInfo;
import android.content.Context;
import android.content.pm.PackageManager;
import android.content.res.ColorStateList;
import android.content.res.Resources;
import android.database.Cursor;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import androidx.appcompat.widget.SearchView;
import com.swing.live.R;
import java.io.FileNotFoundException;
import java.util.List;
import java.util.WeakHashMap;

/* JADX INFO: loaded from: classes.dex */
public final class f0 extends G.b implements View.OnClickListener {

    /* JADX INFO: renamed from: E, reason: collision with root package name */
    public static final /* synthetic */ int f5353E = 0;

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public int f5354A;

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public int f5355B;

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public int f5356C;

    /* JADX INFO: renamed from: D, reason: collision with root package name */
    public int f5357D;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final int f5358o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final int f5359p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final LayoutInflater f5360q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final SearchView f5361r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public final SearchableInfo f5362s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public final Context f5363t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public final WeakHashMap f5364u;
    public final int v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public int f5365w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public ColorStateList f5366x;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public int f5367y;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public int f5368z;

    public f0(Context context, SearchView searchView, SearchableInfo searchableInfo, WeakHashMap weakHashMap) {
        int suggestionRowLayout = searchView.getSuggestionRowLayout();
        this.f477b = true;
        this.f478c = null;
        this.f476a = false;
        this.f479d = context;
        this.e = -1;
        this.f480f = new D2.o(this);
        this.f481m = new G.a(this, 0);
        this.f5359p = suggestionRowLayout;
        this.f5358o = suggestionRowLayout;
        this.f5360q = (LayoutInflater) context.getSystemService("layout_inflater");
        this.f5365w = 1;
        this.f5367y = -1;
        this.f5368z = -1;
        this.f5354A = -1;
        this.f5355B = -1;
        this.f5356C = -1;
        this.f5357D = -1;
        this.f5361r = searchView;
        this.f5362s = searchableInfo;
        this.v = searchView.getSuggestionCommitIconResId();
        this.f5363t = context;
        this.f5364u = weakHashMap;
    }

    public static String h(Cursor cursor, int i4) {
        if (i4 == -1) {
            return null;
        }
        try {
            return cursor.getString(i4);
        } catch (Exception e) {
            Log.e("SuggestionsAdapter", "unexpected error retrieving valid column from cursor, did the remote process die?", e);
            return null;
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:57:0x0134  */
    /* JADX WARN: Removed duplicated region for block: B:58:0x0136  */
    @Override // G.b
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void a(android.view.View r20, android.database.Cursor r21) {
        /*
            Method dump skipped, instruction units count: 422
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: k.f0.a(android.view.View, android.database.Cursor):void");
    }

    @Override // G.b
    public final void b(Cursor cursor) {
        try {
            super.b(cursor);
            if (cursor != null) {
                this.f5367y = cursor.getColumnIndex("suggest_text_1");
                this.f5368z = cursor.getColumnIndex("suggest_text_2");
                this.f5354A = cursor.getColumnIndex("suggest_text_2_url");
                this.f5355B = cursor.getColumnIndex("suggest_icon_1");
                this.f5356C = cursor.getColumnIndex("suggest_icon_2");
                this.f5357D = cursor.getColumnIndex("suggest_flags");
            }
        } catch (Exception e) {
            Log.e("SuggestionsAdapter", "error changing cursor and caching columns", e);
        }
    }

    @Override // G.b
    public final String c(Cursor cursor) {
        String strH;
        String strH2;
        if (cursor == null) {
            return null;
        }
        String strH3 = h(cursor, cursor.getColumnIndex("suggest_intent_query"));
        if (strH3 != null) {
            return strH3;
        }
        SearchableInfo searchableInfo = this.f5362s;
        if (searchableInfo.shouldRewriteQueryFromData() && (strH2 = h(cursor, cursor.getColumnIndex("suggest_intent_data"))) != null) {
            return strH2;
        }
        if (!searchableInfo.shouldRewriteQueryFromText() || (strH = h(cursor, cursor.getColumnIndex("suggest_text_1"))) == null) {
            return null;
        }
        return strH;
    }

    @Override // G.b
    public final View d(ViewGroup viewGroup) {
        View viewInflate = this.f5360q.inflate(this.f5358o, viewGroup, false);
        viewInflate.setTag(new e0(viewInflate));
        ((ImageView) viewInflate.findViewById(R.id.edit_query)).setImageResource(this.v);
        return viewInflate;
    }

    public final Drawable e(Uri uri) throws FileNotFoundException {
        int identifier;
        String authority = uri.getAuthority();
        if (TextUtils.isEmpty(authority)) {
            throw new FileNotFoundException("No authority: " + uri);
        }
        try {
            Resources resourcesForApplication = this.f479d.getPackageManager().getResourcesForApplication(authority);
            List<String> pathSegments = uri.getPathSegments();
            if (pathSegments == null) {
                throw new FileNotFoundException("No path: " + uri);
            }
            int size = pathSegments.size();
            if (size == 1) {
                try {
                    identifier = Integer.parseInt(pathSegments.get(0));
                } catch (NumberFormatException unused) {
                    throw new FileNotFoundException("Single path segment is not a resource ID: " + uri);
                }
            } else {
                if (size != 2) {
                    throw new FileNotFoundException("More than two path segments: " + uri);
                }
                identifier = resourcesForApplication.getIdentifier(pathSegments.get(1), pathSegments.get(0), authority);
            }
            if (identifier != 0) {
                return resourcesForApplication.getDrawable(identifier);
            }
            throw new FileNotFoundException("No resource found for: " + uri);
        } catch (PackageManager.NameNotFoundException unused2) {
            throw new FileNotFoundException("No package found for authority: " + uri);
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:54:0x010c  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final android.graphics.drawable.Drawable f(java.lang.String r11) {
        /*
            Method dump skipped, instruction units count: 276
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: k.f0.f(java.lang.String):android.graphics.drawable.Drawable");
    }

    public final Cursor g(SearchableInfo searchableInfo, String str) {
        String suggestAuthority;
        String[] strArr = null;
        if (searchableInfo == null || (suggestAuthority = searchableInfo.getSuggestAuthority()) == null) {
            return null;
        }
        Uri.Builder builderFragment = new Uri.Builder().scheme("content").authority(suggestAuthority).query("").fragment("");
        String suggestPath = searchableInfo.getSuggestPath();
        if (suggestPath != null) {
            builderFragment.appendEncodedPath(suggestPath);
        }
        builderFragment.appendPath("search_suggest_query");
        String suggestSelection = searchableInfo.getSuggestSelection();
        if (suggestSelection != null) {
            strArr = new String[]{str};
        } else {
            builderFragment.appendPath(str);
        }
        String[] strArr2 = strArr;
        builderFragment.appendQueryParameter("limit", String.valueOf(50));
        return this.f479d.getContentResolver().query(builderFragment.build(), null, suggestSelection, strArr2, null);
    }

    @Override // G.b, android.widget.BaseAdapter, android.widget.SpinnerAdapter
    public final View getDropDownView(int i4, View view, ViewGroup viewGroup) {
        try {
            return super.getDropDownView(i4, view, viewGroup);
        } catch (RuntimeException e) {
            Log.w("SuggestionsAdapter", "Search suggestions cursor threw exception.", e);
            View viewInflate = this.f5360q.inflate(this.f5359p, viewGroup, false);
            if (viewInflate != null) {
                ((e0) viewInflate.getTag()).f5347a.setText(e.toString());
            }
            return viewInflate;
        }
    }

    @Override // G.b, android.widget.Adapter
    public final View getView(int i4, View view, ViewGroup viewGroup) {
        try {
            return super.getView(i4, view, viewGroup);
        } catch (RuntimeException e) {
            Log.w("SuggestionsAdapter", "Search suggestions cursor threw exception.", e);
            View viewD = d(viewGroup);
            ((e0) viewD.getTag()).f5347a.setText(e.toString());
            return viewD;
        }
    }

    @Override // android.widget.BaseAdapter, android.widget.Adapter
    public final boolean hasStableIds() {
        return false;
    }

    @Override // android.widget.BaseAdapter
    public final void notifyDataSetChanged() {
        super.notifyDataSetChanged();
        Cursor cursor = this.f478c;
        Bundle extras = cursor != null ? cursor.getExtras() : null;
        if (extras != null) {
            extras.getBoolean("in_progress");
        }
    }

    @Override // android.widget.BaseAdapter
    public final void notifyDataSetInvalidated() {
        super.notifyDataSetInvalidated();
        Cursor cursor = this.f478c;
        Bundle extras = cursor != null ? cursor.getExtras() : null;
        if (extras != null) {
            extras.getBoolean("in_progress");
        }
    }

    @Override // android.view.View.OnClickListener
    public final void onClick(View view) {
        Object tag = view.getTag();
        if (tag instanceof CharSequence) {
            this.f5361r.n((CharSequence) tag);
        }
    }
}
