package V;

import android.content.res.AssetManager;
import android.os.Build;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.Serializable;
import java.util.concurrent.Executor;

/* JADX INFO: loaded from: classes.dex */
public final class b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Executor f2138a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final e f2139b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final byte[] f2140c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final File f2141d;
    public final String e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public boolean f2142f = false;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public c[] f2143g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public byte[] f2144h;

    public b(AssetManager assetManager, Executor executor, e eVar, String str, File file) {
        this.f2138a = executor;
        this.f2139b = eVar;
        this.e = str;
        this.f2141d = file;
        int i4 = Build.VERSION.SDK_INT;
        byte[] bArr = null;
        if (i4 <= 34) {
            switch (i4) {
                case 24:
                case 25:
                    bArr = f.f2159h;
                    break;
                case 26:
                    bArr = f.f2158g;
                    break;
                case 27:
                    bArr = f.f2157f;
                    break;
                case 28:
                case 29:
                case 30:
                    bArr = f.e;
                    break;
                case 31:
                case 32:
                case 33:
                case 34:
                    bArr = f.f2156d;
                    break;
            }
        }
        this.f2140c = bArr;
    }

    public final FileInputStream a(AssetManager assetManager, String str) {
        try {
            return assetManager.openFd(str).createInputStream();
        } catch (FileNotFoundException e) {
            String message = e.getMessage();
            if (message == null || !message.contains("compressed")) {
                return null;
            }
            this.f2139b.j();
            return null;
        }
    }

    public final void b(final int i4, final Serializable serializable) {
        this.f2138a.execute(new Runnable() { // from class: V.a
            @Override // java.lang.Runnable
            public final void run() {
                this.f2135a.f2139b.f(i4, serializable);
            }
        });
    }
}
