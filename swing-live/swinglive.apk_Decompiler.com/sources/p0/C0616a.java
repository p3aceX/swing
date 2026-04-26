package p0;

import java.io.File;
import java.io.FilenameFilter;

/* JADX INFO: renamed from: p0.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0616a implements FilenameFilter {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ String f6176a;

    public C0616a(String str) {
        this.f6176a = str;
    }

    @Override // java.io.FilenameFilter
    public final boolean accept(File file, String str) {
        return str.startsWith(this.f6176a);
    }
}
