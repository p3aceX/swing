package com.google.android.gms.auth.api.identity;

import A0.a;
import a.AbstractC0184a;
import android.app.PendingIntent;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.common.internal.ReflectedParcelable;
import j1.C0454D;
import java.util.ArrayList;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public class SaveAccountLinkingTokenRequest extends a implements ReflectedParcelable {
    public static final Parcelable.Creator<SaveAccountLinkingTokenRequest> CREATOR = new C0454D(24);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final PendingIntent f3325a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f3326b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f3327c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final ArrayList f3328d;
    public final String e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final int f3329f;

    public SaveAccountLinkingTokenRequest(PendingIntent pendingIntent, String str, String str2, ArrayList arrayList, String str3, int i4) {
        this.f3325a = pendingIntent;
        this.f3326b = str;
        this.f3327c = str2;
        this.f3328d = arrayList;
        this.e = str3;
        this.f3329f = i4;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof SaveAccountLinkingTokenRequest)) {
            return false;
        }
        SaveAccountLinkingTokenRequest saveAccountLinkingTokenRequest = (SaveAccountLinkingTokenRequest) obj;
        ArrayList arrayList = this.f3328d;
        return arrayList.size() == saveAccountLinkingTokenRequest.f3328d.size() && arrayList.containsAll(saveAccountLinkingTokenRequest.f3328d) && F.j(this.f3325a, saveAccountLinkingTokenRequest.f3325a) && F.j(this.f3326b, saveAccountLinkingTokenRequest.f3326b) && F.j(this.f3327c, saveAccountLinkingTokenRequest.f3327c) && F.j(this.e, saveAccountLinkingTokenRequest.e) && this.f3329f == saveAccountLinkingTokenRequest.f3329f;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f3325a, this.f3326b, this.f3327c, this.f3328d, this.e});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.h0(parcel, 1, this.f3325a, i4, false);
        AbstractC0184a.i0(parcel, 2, this.f3326b, false);
        AbstractC0184a.i0(parcel, 3, this.f3327c, false);
        AbstractC0184a.j0(parcel, 4, this.f3328d);
        AbstractC0184a.i0(parcel, 5, this.e, false);
        AbstractC0184a.o0(parcel, 6, 4);
        parcel.writeInt(this.f3329f);
        AbstractC0184a.n0(iM0, parcel);
    }
}
