package T2;

import I.C0053n;
import android.media.CamcorderProfile;
import android.media.EncoderProfiles;

/* JADX INFO: renamed from: T2.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0160e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f1936a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f1937b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Object f1938c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final Object f1939d;
    public final Object e;

    public C0160e(CamcorderProfile camcorderProfile, C0053n c0053n) {
        this.f1938c = camcorderProfile;
        this.f1939d = null;
        this.e = c0053n;
    }

    public C0160e(EncoderProfiles encoderProfiles, C0053n c0053n) {
        this.f1939d = encoderProfiles;
        this.f1938c = null;
        this.e = c0053n;
    }

    public C0160e(int i4, boolean z4, Integer num, Integer num2, Integer num3) {
        this.f1937b = i4;
        this.f1936a = z4;
        this.f1938c = num;
        this.f1939d = num2;
        this.e = num3;
    }
}
