package k;

import android.R;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

/* JADX INFO: loaded from: classes.dex */
public final class e0 {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final TextView f5347a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final TextView f5348b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final ImageView f5349c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final ImageView f5350d;
    public final ImageView e;

    public e0(View view) {
        this.f5347a = (TextView) view.findViewById(R.id.text1);
        this.f5348b = (TextView) view.findViewById(R.id.text2);
        this.f5349c = (ImageView) view.findViewById(R.id.icon1);
        this.f5350d = (ImageView) view.findViewById(R.id.icon2);
        this.e = (ImageView) view.findViewById(com.swing.live.R.id.edit_query);
    }
}
