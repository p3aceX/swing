package s;

import android.content.res.ColorStateList;
import android.content.res.Configuration;
import android.content.res.Resources;

/* JADX INFO: loaded from: classes.dex */
public final class j {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final ColorStateList f6453a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Configuration f6454b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f6455c;

    public j(ColorStateList colorStateList, Configuration configuration, Resources.Theme theme) {
        this.f6453a = colorStateList;
        this.f6454b = configuration;
        this.f6455c = theme == null ? 0 : theme.hashCode();
    }
}
